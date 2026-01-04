public import Foundation

/// An account with an ACME server.
public struct Account: Codable, Sendable {
	/// The key that the account uses to authenticate with the server.
	public var key: Key.Private
	/// The URL that represents the account at the server.
	public var url: URL

	public init(key: Key.Private, url: URL) {
		self.key = key
		self.url = url
	}
}
