package import ACMEAPIModels
package import ACMEClientModels
package import AsyncHTTPClient
package import Foundation
import FzkExtensions

package struct API {
	let httpClient: HTTPClient
	let directory: Directory

	package init(httpClient: HTTPClient = .shared, directory: Directory) {
		self.httpClient = httpClient
		self.directory = directory
	}

	package init(httpClient: HTTPClient = .shared, directory: ACMEDirectory) async throws {
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

		guard response.status.isSuccess
		else {
			let problem = try await response.body.decode(using: coder) as ACMEProblem
			throw problem
		}

		guard let accountURL = response.headers.first(name: "location").flatMap(URL.init(string:))
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
				body: nil,
			)
		)

		guard response.status.isSuccess
		else {
			let problem = try await response.body.decode(using: coder) as ACMEProblem
			throw problem
		}

		return (
			try await response.body.decode(using: coder),
			try response.nonce,
		)
	}

	package func createAccount(nonce: inout Nonce, accountKey: Key.Private, request: NewAccountRequest) async throws -> (account: Account, url: URL)? {
		let response = try await post(
			ACMERequest(
				url: directory.newAccount,
				nonce: nonce,
				accountKey: accountKey,
				accountURL: nil,
				body: request,
			)
		)

		guard response.status.isSuccess
		else {
			let problem = try await response.body.decode(using: coder) as ACMEProblem
			throw problem
		}

		nonce = try response.nonce

		return (
			try await response.body.decode(using: coder),
			try response.headers.first(name: "Location")
				.flatMap(URL.init(string:))
				.unwrap(orThrow: ACMEError.accountURLMissing),
		)
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

		guard response.status.isSuccess
		else {
			let problem = try await response.body.decode(using: coder) as ACMEProblem
			throw problem
		}

		nonce = try response.nonce

		return try await response.body.decode(using: coder)
	}

	private func post(_ acmeRequest: ACMERequest) async throws -> HTTPClientResponse {
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
}
