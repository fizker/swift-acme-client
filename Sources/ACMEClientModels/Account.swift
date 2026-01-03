public import Foundation
public import X509

/// An account with an ACME server.
public struct Account: Codable {
	/// The key that the account uses to authenticate with the server.
	public var key: Certificate.PrivateKey
	/// The URL that represents the account at the server.
	public var url: URL

	public init(key: Certificate.PrivateKey, url: URL) {
		self.key = key
		self.url = url
	}
}
