public import Foundation

public struct NewAccountRequest: Codable {
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

	public init(
		contact: [URL]? = nil,
		termsOfServiceAgreed: Bool? = nil,
		externalAccountBinding: ExternalAccountBinding? = nil,
	) {
		self.contact = contact
		self.termsOfServiceAgreed = termsOfServiceAgreed
		self.externalAccountBinding = externalAccountBinding
	}
}
