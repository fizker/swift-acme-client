import ACMEAPIModels
public import ACMEClientModels
package import Foundation
import Logging

let `1mb` = 1024 * 1024

public class ACMEClient {
	public var account: ACMEClientModels.Account {
		.init(key: accountKey, url: accountURL)
	}
	let accountKey: Key.Private
	let accountURL: URL
	let api: API
	var nonce: Nonce
	let logger = Logger(label: "acme-client")

	/// Creates a new ACMEClient.
	///
	/// This needs an account to already be created and registered with the server.
	/// The ``API/createAccount(request:)`` and ``API/fetchAccount(accountKey:)``
	/// functions can be used to create the `Account`.
	///
	/// - parameters:
	///   - directory: The directory of the server.
	///   - account: The account to use.
	public convenience init(directory: ACMEDirectory, account: ACMEClientModels.Account) async throws {
		try await self.init(directory: directory, accountKey: account.key, accountURL: account.url)
	}

	package init(directory: ACMEDirectory, accountKey: Key.Private, accountURL: URL?) async throws {
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
