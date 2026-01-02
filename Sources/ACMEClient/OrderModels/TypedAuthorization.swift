import ACMEAPIModels
import Foundation
import FzkExtensions

struct TypedAuthorization {
	var identifier: Identifier
	var challenges: [TypedChallenge]
	var url: URL
	var isWildcard: Bool
	var expires: Date?
	var status: Authorization.Status

	init(_ auth: Authorization, url: URL, keyAuth: KeyAuthorization) throws {
		self.url = url
		self.identifier = auth.identifier
		self.challenges = try auth.parseChallenges(keyAuth: keyAuth)
		self.isWildcard = auth.wildcard ?? false
		self.status = auth.status
		self.expires = auth.expires
	}

	func verify(via type: Challenge.`Type`) -> Verification? {
		guard let challenge = challenges.first(where: { $0.type == type })
		else { return nil }

		return Verification(challenge: challenge, auth: self)
	}

	func verify(viaIndex index: Int) -> Verification? {
		guard let challenge = challenges[safe: index]
		else { return nil }

		return Verification(challenge: challenge, auth: self)
	}
}

/// A verification for an `Authorization`.
///
/// This is created through the ``TypedAuthorization``.
struct Verification {
	var challenge: TypedChallenge
	var auth: TypedAuthorization
}
