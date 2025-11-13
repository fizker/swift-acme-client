public import Foundation

/// An ACME account resource represents a set of metadata associated with an account.
///
/// https://datatracker.ietf.org/doc/html/rfc8555#section-7.1.2
public struct Account: Codable, Sendable {
	public enum Status: String, Codable, Sendable {
		case valid, deactivated, revoked
	}

	/// The status of this account.
	///
	/// The value "deactivated" should be used to indicate client-initiated deactivation
	/// whereas "revoked" should be used to indicate server- initiated deactivation.
	/// See [Section 7.1.6](https://datatracker.ietf.org/doc/html/rfc8555#section-7.1.6).
	///
	/// Account objects are created in the "valid" state, since no further
	/// action is required to create an account after a successful `newAccount`
	/// request.  If the account is deactivated by the client or revoked by
	/// the server, it moves to the corresponding state.
	///
	/// ### State Transitions for Account Objects
	/// ```
	///                   valid
	///                     |
	///                     |
	///         +-----------+-----------+
	///  Client |                Server |
	/// deactiv.|                revoke |
	///         V                       V
	///    deactivated               revoked
	/// ```
	public var status: Status

	/// An array of URLs that the server can use to contact the client for issues related to this account.
	///
	/// For example, the server may wish to notify the client about server-initiated revocation or certificate expiration.
	///
	/// For information on supported URL schemes, see [Section 7.3](https://datatracker.ietf.org/doc/html/rfc8555#section-7.3).
	public var contact: [URL]?

	/// Including this field in a newAccount request, with a value of true, indicates the client's agreement with the terms of service.  This field cannot be updated by the client.
	public var termsOfServiceAgreed: Bool?

	/// Including this field in a newAccount request indicates approval by the holder of an existing non-ACME account to bind that account to this ACME account.
	///
	/// This field is not updateable by the client (see [Section 7.3.4](https://datatracker.ietf.org/doc/html/rfc8555#section-7.3.4)).
	public var externalAccountBinding: ExternalAccountBinding?

	/// A URL from which a list of orders submitted by this account can be fetched via a POST-as-GET request,
	/// as described in [Section 7.1.2.1](https://datatracker.ietf.org/doc/html/rfc8555#section-7.1.2.1).
	///
	/// LetsEncrypt never returns a URL here. It is recommended to store URLs to any relevant orders manually.
	public var orders: URL?
}
