public import ACMEAPIModels
public import Crypto
public import Foundation

public struct HTTPChallenge: CustomStringConvertible, Sendable {
	public let url: URL
	public let token: String
	public var type: Challenge.`Type` { .http }
	public let identifier: Identifier

	public let endpoint: HTTPEndpoint

	init(
		challenge: Challenge,
		identifier: Identifier,
		keyAuth: KeyAuthorization,
	) {
		self.url = challenge.url
		self.token = challenge.token
		self.identifier = identifier
		self.endpoint = HTTPEndpoint(
			path: "/.well-known/acme-challenge/\(challenge.token)",
			body: keyAuth.value(for: challenge),
		)
	}

	public var directions: String {
		"""
		For \(identifier), ensure that \(endpoint.path) returns the following response:
		- Status: 200 OK
		- Content-Type: \(endpoint.contentType)
		- Body: \(endpoint.body)
		"""
	}

	public var description: String {
		"HTTP: \(directions)"
	}

	public struct HTTPEndpoint: Sendable {
		public let path: String
		public let body: String
		public let contentType: String = "application/octet-stream"
	}
}
