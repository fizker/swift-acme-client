public import ACMEAPIModels
public import ACMEClientModels
public import AsyncHTTPClient
package import Foundation
import FzkExtensions
import Logging
import X509

/// The `API` for communicating with the ACME server.
public struct API {
	package typealias Account = ACMEAPIModels.Account

	let httpClient: HTTPClient
	let directory: Directory
	let logger = Logger(label: "acme-client.api")

	package init(httpClient: HTTPClient = .shared, directory: Directory) {
		self.httpClient = httpClient
		self.directory = directory
	}

	/// Creates a new API against the specificed directory.
	///
	/// - parameters:
	///   - httpClient: The `HTTPClient` to use for communicating with the ACME server.
	///   - directory: The directory for the ACME server.
	public init(httpClient: HTTPClient = .shared, directory: ACMEDirectory) async throws {
		self.httpClient = httpClient
		self.directory = try await Self.fetchDirectory(for: directory, using: httpClient)
	}

	package static func fetchDirectory(for acmeDirectory: ACMEDirectory, using httpClient: HTTPClient) async throws -> Directory {
		let request = HTTPClientRequest(url: acmeDirectory.rawValue)
		let response = try await httpClient.execute(request, timeout: .seconds(30))
		return try await response.body.decode(using: coder)
	}

	package func fetchNonce() async throws -> Nonce {
		let request = HTTPClientRequest(url: directory.newNonce) ~ {
			$0.method = .HEAD
		}

		let response = try await httpClient.execute(request, timeout: .seconds(30))

		return try response.nonce
	}

	// MARK: - Account

	/// Fetches the account for the given account key.
	///
	/// - parameter accountKey: The private key that is associated with the account.
	/// - returns: The `Account` associated with the given `Key.Private`.
	public func fetchAccount(accountKey: Key.Private) async throws -> ACMEClientModels.Account {
		var nonce = try await fetchNonce()
		let url = try await fetchAccountURL(nonce: &nonce, accountKey: accountKey)
		return .init(key: accountKey, url: url)
	}

	package func fetchAccountURL(nonce: inout Nonce, accountKey: Key.Private) async throws -> URL {
		let (accountURL, newNonce) = try await fetchAccountURL(nonce: nonce, accountKey: accountKey)
		nonce = newNonce
		return accountURL
	}

	package func fetchAccountURL(nonce: Nonce, accountKey: Key.Private) async throws -> (URL, Nonce) {
		let response = try await post(try ACMERequest(
			url: directory.newAccount,
			nonce: nonce,
			accountKey: accountKey,
			accountURL: nil,
			body: ExistingAccountRequest(),
		))

		try await response.assertSuccess()

		guard let accountURL = response.location
		else { throw ACMEError.accountURLMissing }

		return (accountURL, try response.nonce)
	}

	package func fetchAccount(nonce: inout Nonce, accountKey: Key.Private, accountURL: URL) async throws -> Account? {
		let (account, newNonce) = try await fetchAccount(nonce: nonce, accountKey: accountKey, accountURL: accountURL)
		nonce = newNonce
		return account
	}

	package func fetchAccount(nonce: Nonce, accountKey: Key.Private, accountURL: URL) async throws -> (Account?, Nonce) {
		let response = try await post(
			try ACMERequest(
				url: accountURL,
				nonce: nonce,
				accountKey: accountKey,
				accountURL: accountURL,
				body: .getAsPost,
			)
		)

		try await response.assertSuccess()

		return (
			try await response.body.decode(using: coder),
			try response.nonce,
		)
	}

	package func createAccount(nonce: inout Nonce, accountKey: Key.Private, request: NewAccountRequest) async throws -> (account: Account, url: URL) {
		let response = try await post(
			ACMERequest(
				url: directory.newAccount,
				nonce: nonce,
				accountKey: accountKey,
				accountURL: nil,
				body: request,
			)
		)

		try await response.assertSuccess()

		nonce = try response.nonce

		return (
			try await response.body.decode(using: coder),
			try response.headers.first(name: "Location")
				.flatMap(URL.init(string:))
				.unwrap(orThrow: ACMEError.accountURLMissing),
		)
	}

	/// Creates a new `Account` and private key.
	///
	/// - parameter request: The request required for creating a new account.
	/// - returns: The created account.
	public func createAccount(request: NewAccountRequest) async throws -> ACMEClientModels.Account {
		var nonce = try await fetchNonce()
		let accountKey = Key.Private()
		let response = try await createAccount(nonce: &nonce, accountKey: accountKey, request: request)
		return .init(key: accountKey, url: response.url)
	}

	/// Creates a new `Account` using the given key.
	///
	/// - parameters:
	///   - accountKey: The private key for the account.
	///   - request: The request required for creating a new account.
	/// - returns: The created account.
	public func createAccount(accountKey: Key.Private, request: NewAccountRequest) async throws -> ACMEClientModels.Account {
		var nonce = try await fetchNonce()
		let response = try await createAccount(nonce: &nonce, accountKey: accountKey, request: request)
		return .init(key: accountKey, url: response.url)
	}

	@discardableResult
	package func update(_ request: NewAccountRequest, nonce: inout Nonce, accountKey: Key.Private, accountURL: URL) async throws -> Account {
		let response = try await post(
			ACMERequest(
				url: accountURL,
				nonce: nonce,
				accountKey: accountKey,
				accountURL: accountURL,
				body: request,
			)
		)

		try await response.assertSuccess()

		nonce = try response.nonce

		return try await response.body.decode(using: coder)
	}

	// MARK: - Order

	func createOrder(_ request: NewOrderRequest, nonce: inout Nonce, accountKey: Key.Private, accountURL: URL) async throws -> (Order, URL) {
		let response = try await post(
			ACMERequest(
				url: directory.newOrder,
				nonce: nonce,
				accountKey: accountKey,
				accountURL: accountURL,
				body: request,
			)
		)

		try await response.assertSuccess()

		nonce = try response.nonce

		guard let url = response.location
		else { throw ACMEError.orderURLMissing }

		return (
			try await response.body.decode(using: coder),
			url,
		)
	}

	func order(url: URL, nonce: inout Nonce, accountKey: Key.Private, accountURL: URL) async throws -> Order {
		// The nonce from outside failed with `JWS has an invalid anti-replay nonce`,
		// so we spend a call here to ensure a nonce
		nonce = try await fetchNonce()
		let response = try await post(
			ACMERequest(
				url: url,
				nonce: nonce,
				accountKey: accountKey,
				accountURL: accountURL,
				body: .getAsPost,
			)
		)

		try await response.assertSuccess()

		nonce = try response.nonce

		return try await response.body.decode(using: coder)
	}

	func finalize(order: Order, orderURL: URL, nonce: inout Nonce, accountKey: Key.Private, accountURL: URL) async throws -> (Order, Certificate.PrivateKey) {
		let domains = order.identifiers.map(\.value)

		let privateKey = Certificate.PrivateKey(try .init(keySize: .bits2048))
		let commonName = domains[0]
		let name = try DistinguishedName {
			CommonName(commonName)
		}
		let extensions = try Certificate.Extensions {
			SubjectAlternativeNames(domains.map({ GeneralName.dnsName($0) }))
		}
		let extensionRequest = ExtensionRequest(extensions: extensions)
		let attributes = try CertificateSigningRequest.Attributes(
			[.init(extensionRequest)]
		)
		let csr = try CertificateSigningRequest(
			version: .v1,
			subject: name,
			privateKey: privateKey,
			attributes: attributes,
			signatureAlgorithm: .sha256WithRSAEncryption
		)

		let response = try await post(
			ACMERequest(
				url: order.finalize,
				nonce: nonce,
				accountKey: accountKey,
				accountURL: accountURL,
				body: FinalizeOrderRequest(csr: csr),
			)
		)

		try await response.assertSuccess()

		nonce = try response.nonce

		return (
			try await self.order(
				url: orderURL,
				nonce: &nonce,
				accountKey: accountKey,
				accountURL: accountURL,
			),
			privateKey,
		)
	}

	func authorization(at url: URL, nonce: inout Nonce, accountKey: Key.Private, accountURL: URL) async throws -> Authorization {
		let response = try await post(
			ACMERequest(
				url: url,
				nonce: nonce,
				accountKey: accountKey,
				accountURL: accountURL,
				body: .getAsPost
			)
		)

		try await response.assertSuccess()

		nonce = try response.nonce

		return try await response.body.decode(using: coder)
	}

	func respondTo(
		_ challenge: Challenge,
		nonce: inout Nonce,
		accountKey: Key.Private,
		accountURL: URL,
	) async throws -> Challenge {
		try await respondTo(
			challengeURL: challenge.url,
			nonce: &nonce,
			accountKey: accountKey,
			accountURL: accountURL,
		)
	}

	func respondTo(
		_ challenge: TypedChallenge,
		nonce: inout Nonce,
		accountKey: Key.Private,
		accountURL: URL,
	) async throws -> Challenge {
		try await respondTo(
			challengeURL: challenge.url,
			nonce: &nonce,
			accountKey: accountKey,
			accountURL: accountURL,
		)
	}

	private func respondTo(
		challengeURL: URL,
		nonce: inout Nonce,
		accountKey: Key.Private,
		accountURL: URL,
	) async throws -> Challenge {
		let response = try await post(ACMERequest(
			url: challengeURL,
			nonce: nonce,
			accountKey: accountKey,
			accountURL: accountURL,
			body: .emptyBody,
		))
		try await response.assertSuccess()
		nonce = try response.nonce

		return try await response.body.decode(using: coder)
	}

	func downloadCertificateChain(for order: Order, nonce: inout Nonce, accountKey: Key.Private, accountURL: URL) async throws -> CertificateChain {
		guard
			order.status == .valid,
			let certificateURL = order.certificate
		else {
			throw ACMEProblem(
				type: .orderNotReady,
				detail: "Order must be ready before attempting certificate download. Status: \(order.status), certificate: \(order.certificate, default: "nil")",
			)
		}

		let certResponse = try await post(
			ACMERequest(
				url: certificateURL,
				nonce: nonce,
				accountKey: accountKey,
				accountURL: accountURL,
				body: .getAsPost,
			)
		)
		try await certResponse.assertSuccess()

		nonce = try certResponse.nonce

		let rawBody = try await certResponse.body.collect(upTo: Int.max)
		let string = String(buffer: rawBody)

		let separator = "-----END CERTIFICATE-----\n"
		let pemCertificates = string.split(separator: separator).map { "\($0)\(separator)" }

		return try CertificateChain(certificates: pemCertificates.map { try CertificateData(pemEncoded: $0, isSelfSigned: false) })
	}

	// MARK: -

	private func post(_ acmeRequest: ACMERequest) async throws -> HTTPClientResponse {
		logger.trace("Sending ACME request to \(acmeRequest.url)")
		defer { logger.trace("Sending ACME request to \(acmeRequest.url) - completed") }

		var request = HTTPClientRequest(url: acmeRequest.url)
		request.headers.add(name: "content-type", value: "application/jose+json")
		request.method = .POST
		let data = try coder.encoder.encode(acmeRequest)
		request.body = .bytes(data)

		return try await httpClient.execute(request, timeout: .seconds(30))
	}
}

extension HTTPClientResponse {
	var nonce: Nonce {
		get throws {
			guard let nonce = headers["replay-nonce"].first
			else { throw ACMEError.nonceMissing }

			return nonce
		}
	}

	/// Tries to parse a URL from the location header.
	var location: URL? {
		headers.first(name: "location").flatMap(URL.init(string:))
	}

	func assertSuccess() async throws {
		guard status.isSuccess
		else {
			let problem = try await body.decode(using: coder) as ACMEProblem
			throw problem
		}
	}
}
