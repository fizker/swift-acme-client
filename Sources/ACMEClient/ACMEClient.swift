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

	public init(directory: ACMEDirectory, accountKey: Key.Private, accountURL: URL?) async throws {
		self.accountKey = accountKey
		api = try await API(directory: directory)
		var nonce = try await api.fetchNonce()
		if let accountURL {
			self.accountURL = accountURL
		} else {
			self.accountURL = try await api.fetchAccountURL(nonce: &nonce, accountKey: accountKey)
			print("Fetched account URL: \(self.accountURL)")
		}
		self.nonce = nonce
	}

	public func requestCertificateViaDNS(covering domains: [Domain]) async throws {
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
			for challenge in auth.challenges {
				print("Challenge:\n\(challenge, indentedWith: "- ")")
			}
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

	public init?(_ string: String) {
		guard !string.isEmpty
		else { return nil }

		value = string
	}
}
