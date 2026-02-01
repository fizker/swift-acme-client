public import ACMEAPIModels
public import Foundation
import FzkExtensions

/// A more strongly typed variant of the ``ACMEAPIModels/Authorization`` type.
///
/// An ACME authorization object represents a server's authorization for
/// an account to represent an identifier.  In addition to the
/// identifier, an authorization includes several metadata fields, such
/// as the status of the authorization (e.g., "pending", "valid", or
/// "revoked") and which challenges were used to validate possession of
/// the identifier.
public struct TypedAuthorization: Sendable {
	/// The identifier that the authorization is for.
	public let identifier: Identifier
	/// For pending authorizations,
	/// the challenges that the client can fulfill in order to prove
	/// possession of the identifier.  For valid authorizations, the
	/// challenge that was validated.  For invalid authorizations, the
	/// challenge that was attempted and failed.  Each array entry is an
	/// object with parameters required to validate the challenge.  A
	/// client should attempt to fulfill one of these challenges, and a
	/// server should consider any one of the challenges sufficient to
	/// make the authorization valid.
	public let challenges: [TypedChallenge]
	/// The URL for the Authorization.
	public let url: URL
	/// This field MUST be present and true
	/// for authorizations created as a result of a newOrder request
	/// containing a DNS identifier with a value that was a wildcard
	/// domain name.  For other authorizations, it MUST be absent.
	/// Wildcard domain names are described in Section 7.1.3.
	public let isWildcard: Bool
	/// The timestamp after which the server
	/// will consider this authorization invalid, encoded in the format
	/// specified in [RFC3339].  This field is REQUIRED for objects with
	/// "valid" in the "status" field.
	public let expires: Date?
	/// The status of this authorization.
	///
	/// https://datatracker.ietf.org/doc/html/rfc8555#section-7.1.6
	///
	/// Authorization objects are created in the "pending" state.  If one of
	/// the challenges listed in the authorization transitions to the "valid"
	/// state, then the authorization also changes to the "valid" state.  If
	/// the client attempts to fulfill a challenge and fails, or if there is
	/// an error while the authorization is still pending, then the
	/// authorization transitions to the "invalid" state.  Once the
	/// authorization is in the "valid" state, it can expire ("expired"), be
	/// deactivated by the client ("deactivated", see Section 7.5.2), or
	/// revoked by the server ("revoked").
	///
	/// ### State Transitions for Authorization Objects
	/// ```
	///                pending --------------------+
	///                   |                        |
	/// Challenge failure |                        |
	///        or         |                        |
	///       Error       |  Challenge valid       |
	///         +---------+---------+              |
	///         |                   |              |
	///         V                   V              |
	///      invalid              valid            |
	///                             |              |
	///                             |              |
	///                             |              |
	///              +--------------+--------------+
	///              |              |              |
	///              |              |              |
	///       Server |       Client |   Time after |
	///       revoke |   deactivate |    "expires" |
	///              V              V              V
	///           revoked      deactivated      expired
	/// ```
	public let status: Authorization.Status

	/// Creates a new typed Authorization by combining each challenge with the given ``KeyAuthorization``.
	///
	/// - Parameters:
	///   - auth: The authorization to wrap.
	///   - url: The URL for the authorization.
	///   - keyAuth: The ``KeyAuthorization`` to use when creating ``TypedChallenge``s.
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
public struct Verification: Sendable {
	/// The challenge that should be verified.
	public let challenge: TypedChallenge
	/// The authorization that issued the challenge.
	public let auth: TypedAuthorization
}
