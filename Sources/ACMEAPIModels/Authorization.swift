import Foundation

/// An ACME authorization object represents a server's authorization for
/// an account to represent an identifier.  In addition to the
/// identifier, an authorization includes several metadata fields, such
/// as the status of the authorization (e.g., "pending", "valid", or
/// "revoked") and which challenges were used to validate possession of
/// the identifier.
struct Authorization: Codable {
	var identifier: Identifier

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
	var status: Status

	/// The timestamp after which the server
	/// will consider this authorization invalid, encoded in the format
	/// specified in [RFC3339].  This field is REQUIRED for objects with
	/// "valid" in the "status" field.
	var expires: Date?

	/// For pending authorizations,
	/// the challenges that the client can fulfill in order to prove
	/// possession of the identifier.  For valid authorizations, the
	/// challenge that was validated.  For invalid authorizations, the
	/// challenge that was attempted and failed.  Each array entry is an
	/// object with parameters required to validate the challenge.  A
	/// client should attempt to fulfill one of these challenges, and a
	/// server should consider any one of the challenges sufficient to
	/// make the authorization valid.
	var challenges: [Challenge]

	/// This field MUST be present and true
	/// for authorizations created as a result of a newOrder request
	/// containing a DNS identifier with a value that was a wildcard
	/// domain name.  For other authorizations, it MUST be absent.
	/// Wildcard domain names are described in Section 7.1.3.
	var wildcard: Bool?

	enum Status: String, Codable {
		case pending, valid, invalid, deactivated, expired, revoked
	}
}
