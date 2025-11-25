public import Foundation

/// An ACME order object

/// An ACME order object represents a client's request for a certificate
/// and is used to track the progress of that order through to issuance.
/// Thus, the object contains information about the requested
/// certificate, the authorizations that the server requires the client
/// to complete, and any certificates that have resulted from this order.
///
/// https://datatracker.ietf.org/doc/html/rfc8555#section-7.1.3
///
/// The elements of the "authorizations" and "identifiers" arrays are
/// immutable once set.  The server MUST NOT change the contents of
/// either array after they are created.  If a client observes a change
/// in the contents of either array, then it SHOULD consider the order
/// invalid.
///
/// The "authorizations" array of the order SHOULD reflect all
/// authorizations that the CA takes into account in deciding to issue,
/// even if some authorizations were fulfilled in earlier orders or in
/// pre-authorization transactions.  For example, if a CA allows multiple
/// orders to be fulfilled based on a single authorization transaction,
/// then it SHOULD reflect that authorization in all of the orders.
///
/// Note that just because an authorization URL is listed in the
/// "authorizations" array of an order object doesn't mean that the
/// client is required to take action.  There are several reasons that
/// the referenced authorizations may already be valid:
///
/// - The client completed the authorization as part of a previous order
/// - The client previously pre-authorized the identifier (see Section 7.4.1)
/// - The server granted the client authorization based on an external account
///
/// Clients SHOULD check the "status" field of an order to determine
/// whether they need to take any action.
public struct Order: Codable {
	public init(status: Status, expires: Date? = nil, identifiers: [Identifier], notBefore: Date? = nil, notAfter: Date? = nil, error: ACMEProblem? = nil, authorizations: [URL], finalize: URL, certificate: URL? = nil) {
		self.status = status
		self.expires = expires
		self.identifiers = identifiers
		self.notBefore = notBefore
		self.notAfter = notAfter
		self.error = error
		self.authorizations = authorizations
		self.finalize = finalize
		self.certificate = certificate
	}

	/// The status of this order
	///
	/// Order objects are created in the "pending" state.  Once all of the
	/// authorizations listed in the order object are in the "valid" state,
	/// the order transitions to the "ready" state.  The order moves to the
	/// "processing" state after the client submits a request to the order's
	/// "finalize" URL and the CA begins the issuance process for the
	/// certificate.  Once the certificate is issued, the order enters the
	/// "valid" state.  If an error occurs at any of these stages, the order
	/// moves to the "invalid" state.  The order also moves to the "invalid"
	/// state if it expires or one of its authorizations enters a final state
	/// other than "valid" ("expired", "revoked", or "deactivated").
	///
	/// ### State Transitions for Order Objects
	/// ```
	///  pending --------------+
	///     |                  |
	///     | All authz        |
	///     | "valid"          |
	///     V                  |
	///   ready ---------------+
	///     |                  |
	///     | Receive          |
	///     | finalize         |
	///     | request          |
	///     V                  |
	/// processing ------------+
	///     |                  |
	///     | Certificate      | Error or
	///     | issued           | Authorization failure
	///     V                  V
	///   valid             invalid
	/// ```
	public var status: Status

	/// The timestamp after which the server will consider this order invalid, encoded in the format specified in [RFC3339].  This field is REQUIRED for objects with "pending" or "valid" in the status field.
	public var expires: Date?

	/// An array of identifier objects that the order pertains to.
	public var identifiers: [Identifier]

	/// The requested value of the notBefore field in the certificate, in the date format defined in [RFC3339].
	public var notBefore: Date?

	/// The requested value of the notAfter field in the certificate, in the date format defined in [RFC3339].
	public var notAfter: Date?

	/// The error that occurred while processing the order, if any.
	///
	/// This field is structured as a problem document [RFC7807].
	public var error: ACMEProblem?

	/// For pending orders, the authorizations that the client needs to complete before the requested
	/// certificate can be issued (see Section 7.5), including unexpired authorizations that the client has
	/// completed in the past for identifiers specified in the order.
	///
	/// The authorizations required are dictated by server policy; there may not be a 1:1 relationship
	/// between the order identifiers and the authorizations required.
	/// For final orders (in the "valid" or "invalid" state), the authorizations that were completed.
	///
	/// Each entry is a URL from which an authorization can be fetched with a POST-as-GET request.
	public var authorizations: [URL]

	/// A URL that a CSR must be POSTed to once all of the order's authorizations are satisfied to finalize the order.
	/// The result of a successful finalization will be the population of the certificate URL for the order.
	public var finalize: URL

	/// A URL for the certificate that has been issued in response to this order.
	public var certificate: URL?

	/// The status of an order.
	///
	/// https://datatracker.ietf.org/doc/html/rfc8555#section-7.1.6
	public enum Status: String, Codable {
		case pending
		case ready
		case processing
		case valid
		case invalid
	}
}
