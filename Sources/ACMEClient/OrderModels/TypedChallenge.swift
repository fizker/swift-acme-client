import ACMEAPIModels
import Foundation

enum TypedChallenge: CustomStringConvertible {
	case dns(DNSChallenge)
	case other(Challenge)

	var url: URL {
		switch self {
		case let .dns(challenge):
			challenge.url
		case let .other(challenge):
			challenge.url
		}
	}

	var type: Challenge.`Type` {
		switch self {
		case let .dns(challenge):
			challenge.type
		case let .other(challenge):
			challenge.type
		}
	}

	var token: String {
		switch self {
		case let .dns(challenge):
			challenge.token
		case let .other(challenge):
			challenge.token
		}
	}

	/// The directions for how to pass this challenge.
	var directions: String {
		switch self {
		case let .dns(challenge):
			challenge.directions
		case let .other(challenge):
			"Unsupported challenge:\n\(challenge.description, indentedWith: "- ")"
		}
	}

	var description: String { directions }
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
