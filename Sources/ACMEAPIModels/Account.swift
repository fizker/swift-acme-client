import Foundation

/// An ACME account resource represents a set of metadata associated with an account.
///
/// https://datatracker.ietf.org/doc/html/rfc8555#section-7.1.2
struct Account: Codable {
	enum Status: String, Codable {
		case valid, deactivated, revoked
	}

	/// The status of this account.
	///
	/// The value "deactivated" should be used to indicate client-initiated deactivation
	/// whereas "revoked" should be used to indicate server- initiated deactivation.
	/// See [Section 7.1.6](https://datatracker.ietf.org/doc/html/rfc8555#section-7.1.6).
	var status: Status

	/// An array of URLs that the server can use to contact the client for issues related to this account.
	///
	/// For example, the server may wish to notify the client about server-initiated revocation or certificate expiration.
	///
	/// For information on supported URL schemes, see [Section 7.3](https://datatracker.ietf.org/doc/html/rfc8555#section-7.3).
	var contact: [URL]?

	/// Including this field in a newAccount request, with a value of true, indicates the client's agreement with the terms of service.  This field cannot be updated by the client.
	var termsOfServiceAgreed: Bool?

	/// Including this field in a newAccount request indicates approval by the holder of an existing non-ACME account to bind that account to this ACME account.
	///
	/// This field is not updateable by the client (see [Section 7.3.4](https://datatracker.ietf.org/doc/html/rfc8555#section-7.3.4)).
	var externalAccountBinding: ExternalAccountBinding?

	/// A URL from which a list of orders submitted by this account can be fetched via a POST-as-GET request,
	/// as described in [Section 7.1.2.1](https://datatracker.ietf.org/doc/html/rfc8555#section-7.1.2.1).
	var orders: URL
}
