import ACMEAPIModels
public import ACMEClientModels
public import Foundation

let `1mb` = 1024 * 1024

public class ACMEClient {
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
