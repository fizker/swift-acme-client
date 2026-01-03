public import ACMEAPIModels
public import Foundation

public enum TypedChallenge: CustomStringConvertible {
	case dns(DNSChallenge)
	case other(Challenge)

	public var url: URL {
		switch self {
		case let .dns(challenge):
			challenge.url
		case let .other(challenge):
			challenge.url
		}
	}

	public var type: Challenge.`Type` {
		switch self {
		case let .dns(challenge):
			challenge.type
		case let .other(challenge):
			challenge.type
		}
	}

	public var token: String {
		switch self {
		case let .dns(challenge):
			challenge.token
		case let .other(challenge):
			challenge.token
		}
	}

	/// The directions for how to pass this challenge.
	public var directions: String {
		switch self {
		case let .dns(challenge):
			challenge.directions
		case let .other(challenge):
			"Unsupported challenge:\n\(challenge.description, indentedWith: "- ")"
		}
	}

	public var description: String { directions }
}

extension Authorization {
	func parseChallenges(keyAuth: KeyAuthorization) throws -> [TypedChallenge] {
		try challenges.map {
			switch $0.type {
			case .dns:
				.dns(try DNSChallenge($0, identifier: identifier, keyAuth: keyAuth))
			case .http, .tlsALPN, .unknown:
				.other($0)
			}
		}
	}
}
