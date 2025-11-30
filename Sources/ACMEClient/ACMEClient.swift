import ACMEAPIModels
public import ACMEClientModels
public import Foundation
import FzkExtensions

let `1mb` = 1024 * 1024

public actor ACMEClient {
	let accountKey: Key.Private
	let accountURL: URL
	let api: API
	var nonce: Nonce

	public init(directory: ACMEDirectory, accountKey: Key.Private, accountURL: URL) async throws {
		self.accountKey = accountKey
		self.accountURL = accountURL
		api = try await API(directory: directory)
		nonce = try await api.fetchNonce()
	}

	func requestCertificateViaDNS(covering domains: [Domain]) async throws {
		var nonce = nonce
		let (order, orderURL) = try await api.createOrder(
			NewOrderRequest(identifiers: domains.map { Identifier(type: .dns, value: $0.value) }),
			nonce: &nonce,
			accountKey: accountKey,
			accountURL: accountURL,
		)

		guard order.status != .invalid
		else { throw CustomError(message: "Could not initiate order") }

		for url in order.authorizations {
			let auth = try await api.authorization(at: url, nonce: &nonce, accountKey: accountKey, accountURL: accountURL)
			guard auth.status == .pending
			else {
				print("Auth for \(auth.identifier.value) is \(auth.status)")
				continue
			}

			print("Auth for \(auth.identifier.value) is pending")
			print("There are \(auth.challenges.count) challenges available")
		}

		// Wait for challenges to be resolved
		// Communicate with the server to continue
	}
}

struct CustomError: Error {
	var message: String

	init(message: String) {
		self.message = message
	}
}

public struct Domain {
	let value: String

	init?(_ string: String) {
		guard !string.isEmpty
		else { return nil }

		value = string
	}
}
