public import Foundation

public struct LetsEncryptChallenge: Codable, Equatable, Sendable {
	public typealias Status = Challenge.Status

	public var status: Status
	public var token: String
	public var type: `Type`
	public var url: URL

	public init(status: Status, token: String, type: `Type`, url: URL) {
		self.status = status
		self.token = token
		self.type = type
		self.url = url
	}

	/// https://letsencrypt.org/docs/challenge-types/
	public enum `Type`: String, Codable, Sendable {
		/// https://datatracker.ietf.org/doc/html/rfc8737
		/// https://letsencrypt.org/docs/challenge-types/#tls-alpn-01
		case tlsALPN = "tls-alpn-01"
		/// https://letsencrypt.org/docs/challenge-types/#dns-01-challenge
		case dns = "dns-01"
		/// https://letsencrypt.org/docs/challenge-types/#http-01-challenge
		case http = "http-01"
	}
}

extension LetsEncryptChallenge: CustomStringConvertible {
	public var description: String {
		"""
		status: "\(status)"
		token: "\(token)"
		type: "\(type.rawValue)"
		url: "\(url)"
		"""
	}
}
