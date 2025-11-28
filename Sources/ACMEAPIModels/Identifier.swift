public struct Identifier: Codable, Equatable, Sendable {
	public enum `Type`: Codable, Equatable, Sendable {
		/// Any identifier of type "dns" in a newOrder request MAY have a
		/// wildcard domain name as its value.
		///
		/// A wildcard domain name consists
		/// of a single asterisk character followed by a single full stop
		/// character (`"*."`) followed by a domain name as defined for use in the
		/// Subject Alternate Name Extension by [RFC5280].  An authorization
		/// returned by the server for a wildcard domain name identifier MUST NOT
		/// include the asterisk and full stop (`"*."`) prefix in the authorization
		/// identifier value.
		///
		/// The returned authorization MUST include the
		/// optional "wildcard" field, with a value of true.
		case dns

		/// Catch-all for any types not yet known by this codebase.
		case unknown(String)

		public func encode(to encoder: any Encoder) throws {
			var container = encoder.singleValueContainer()
			switch self {
			case .dns: try container.encode("dns")
			case let .unknown(value): try container.encode(value)
			}
		}

		public init(from decoder: any Decoder) throws {
			let container = try decoder.singleValueContainer()
			let value = try container.decode(String.self)
			switch value {
				case "dns": self = .dns
				default: self = .unknown(value)
			}
		}
	}

	/// The type of identifier.
	///
	/// This document defines the "dns" identifier type.  See the registry defined in Section 9.7.7 for any others.
	public var type: `Type`

	/// The identifier itself.
	public var value: String

	public init(type: `Type`, value: String) {
		self.type = type
		self.value = value
	}
}
