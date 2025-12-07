public enum Challenge: Equatable, Sendable {
	case unknown(GenericChallenge)
	case letsEncrypt(LetsEncryptChallenge)

	var status: Status {
		switch self {
		case let .unknown(value): return value.status
		case let .letsEncrypt(value): return value.status
		}
	}

	public enum Status: String, Codable, Sendable {
		case pending, processing, valid, invalid
	}
}

extension Challenge: Codable {
	public init(from decoder: any Decoder) throws {
		if let le = try? LetsEncryptChallenge(from: decoder) {
			self = .letsEncrypt(le)
		} else {
			self = try .unknown(.init(from: decoder))
		}
	}

	public func encode(to encoder: any Encoder) throws {
		switch self {
		case let .letsEncrypt(value):
			try value.encode(to: encoder)
		case let .unknown(value):
			try value.encode(to: encoder)
		}
	}
}

extension Challenge: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .letsEncrypt(value):
			return value.description
		case let .unknown(value):
			return value.description
		}
	}
}
