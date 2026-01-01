import ACMEAPIModels
public import ACMEClientModels
public import Foundation
import Logging

let `1mb` = 1024 * 1024

public class ACMEClient {
	let accountKey: Key.Private
	let accountURL: URL
	let api: API
	var nonce: Nonce
	let logger = Logger(label: "acme-client")

	public init(directory: ACMEDirectory, accountKey: Key.Private, accountURL: URL?) async throws {
		self.accountKey = accountKey

		logger.trace("Requesting directory")
		api = try await API(directory: directory)

		logger.trace("Requesting nonce")
		var nonce = try await api.fetchNonce()

		if let accountURL {
			self.accountURL = accountURL
		} else {
			logger.trace("Fetching account URL")
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
