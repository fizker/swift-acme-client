import Foundation

/// The directory the the ACME server.
///
/// In order to help clients configure themselves with the right URLs for each ACME operation,
/// ACME servers provide a directory object.  This should be the only URL needed to configure clients.
/// It is a JSON object, whose field names are drawn from the resource registry ([Section 9.7.5](https://datatracker.ietf.org/doc/html/rfc8555#section-9.7.5))
/// and whose values are the corresponding URLs.
///
/// https://datatracker.ietf.org/doc/html/rfc8555#section-7.1.1
struct Directory: Codable {
	/// New nonce
	var newNonce: URL

	/// New account
	var newAccount: URL

	/// New order
	var newOrder: URL

	/// New authorization
	var newAuthz: URL?

	/// Revoke certificate
	var revokeCert: URL

	/// Key change
	var keyChange: URL

	/// Each field in the object is an item of metadata relating to the service provided by the ACME server.
	///
	/// https://datatracker.ietf.org/doc/html/rfc8555#section-9.7.6
	var meta: Metadata?

	struct Metadata: Codable {
		/// A URL identifying the current terms of service.
		var termsOfService: URL?

		/// An HTTP or HTTPS URL locating a website providing more information about the ACME server.
		var website: URL?

		/// The hostnames that the ACME server recognizes as referring to itself.
		///
		/// The hostnames that the ACME server recognizes as referring to itself for the purposes of CAA record validation as defined in [RFC6844].  Each string MUST represent the same sequence of ASCII code points that the server will expect to see as the "Issuer Domain Name" in a CAA issue or issuewild property tag.  This allows clients to determine the correct issuer domain name to use when configuring CAA records.
		var caaIdentities: [String]?

		/// Is `externalAccountBinding` field required for `newAccount` requests.
		///
		/// If this field is present and set to "true", then the CA requires that all newAccount requests include an "externalAccountBinding" field associating the new account with an external account.
		var externalAccountRequired: Bool?
	}
}
