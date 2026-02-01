public import Foundation

/// An ACME challenge object represents a server's offer to validate a
/// client's possession of an identifier in a specific way.  Unlike the
/// other objects listed above, there is not a single standard structure
/// for a challenge object.  The contents of a challenge object depend on
/// the validation method being used.  The general structure of challenge
/// objects and an initial set of validation methods are described in
/// [Section 8](https://datatracker.ietf.org/doc/html/rfc8555#section-8).
public struct Challenge: Codable, Equatable, Sendable {
	/// Status of the challenge.
	///
	/// Challenge objects are created in the "pending" state.  They
	/// transition to the "processing" state when the client responds to the
	/// challenge (see Section 7.5.1) and the server begins attempting to
	/// validate that the client has completed the challenge.  Note that
	/// within the "processing" state, the server may attempt to validate the
	/// challenge multiple times (see Section 8.2).  Likewise, client
	/// requests for retries do not cause a state change.  If validation is
	/// successful, the challenge moves to the "valid" state; if there is an
	/// error, the challenge moves to the "invalid" state.
	///
	/// ### State Transitions for Challenge Objects
	/// ```
	///          pending
	///             |
	///             | Receive
	///             | response
	///             V
	///         processing <-+
	///             |   |    | Server retry or
	///             |   |    | client retry request
	///             |   +----+
	///             |
	///             |
	/// Successful  |   Failed
	/// validation  |   validation
	///   +---------+---------+
	///   |                   |
	///   V                   V
	/// valid              invalid
	/// ```
	public var status: Status

	/// The type of challenge.
	public var type: `Type`
	/// The URL to post to when the challenge is ready for processing.
	public var url: URL
	public var token: String

	public init(status: Status, token: String, type: Type, url: URL) {
		self.status = status
		self.type = type
		self.url = url
		self.token = token
	}

	/// https://letsencrypt.org/docs/challenge-types/
	public enum `Type`: Codable, Equatable, Hashable, RawRepresentable, Sendable {
		/// https://datatracker.ietf.org/doc/html/rfc8737
		/// https://letsencrypt.org/docs/challenge-types/#tls-alpn-01
		case tlsALPN
		/// https://datatracker.ietf.org/doc/html/rfc8555#section-8.4
		/// https://letsencrypt.org/docs/challenge-types/#dns-01-challenge
		case dns
		/// https://datatracker.ietf.org/doc/html/rfc8555#section-8.3
		/// https://letsencrypt.org/docs/challenge-types/#http-01-challenge
		case http

		/// Catch-all for unknown types
		case unknown(String)

		public init?(rawValue: String) {
			switch rawValue {
			case "tls-alpn-01": self = .tlsALPN
			case "dns-01": self = .dns
			case "http-01": self = .http
			default: self = .unknown(rawValue)
			}
		}

		public var rawValue: String {
			switch self {
			case .tlsALPN: "tls-alpn-01"
			case .dns: "dns-01"
			case .http: "http-01"
			case let .unknown(rawValue): rawValue
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			let value = try container.decode(String.self)
			guard let supportedType = Self(rawValue: value)
			else {
				throw DecodingError.dataCorruptedError(
					in: container,
					debugDescription: "Unsupported challenge type: \(value)"
				)
			}

			self = supportedType
		}
	}

	public enum Status: String, Codable, Sendable {
		case pending, processing, valid, invalid
	}
}

extension Challenge: CustomStringConvertible {
	public var description: String {
		"""
		status: "\(status)"
		token: "\(token)"
		type: "\(type.rawValue)"
		url: "\(url)"
		"""
	}
}
