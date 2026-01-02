public import ACMEAPIModels
public import Foundation
import FzkExtensions

public struct TypedAuthorization {
	public let identifier: Identifier
	public let challenges: [TypedChallenge]
	public let url: URL
	public let isWildcard: Bool
	public let expires: Date?
	public let status: Authorization.Status

	init(_ auth: Authorization, url: URL, keyAuth: KeyAuthorization) throws {
		self.url = url
		self.identifier = auth.identifier
		self.challenges = try auth.parseChallenges(keyAuth: keyAuth)
		self.isWildcard = auth.wildcard ?? false
		self.status = auth.status
		self.expires = auth.expires
	}

	public func verify(via type: Challenge.`Type`) -> Verification? {
		guard let challenge = challenges.first(where: { $0.type == type })
		else { return nil }

		return Verification(challenge: challenge, auth: self)
	}

	public func verify(viaIndex index: Int) -> Verification? {
		guard let challenge = challenges[safe: index]
		else { return nil }

		return Verification(challenge: challenge, auth: self)
	}
}

/// A verification for an `Authorization`.
///
/// This is created through the ``TypedAuthorization``.
public struct Verification {
	public let challenge: TypedChallenge
	public let auth: TypedAuthorization
}
