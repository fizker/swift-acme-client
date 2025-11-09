import Foundation

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
struct Order: Codable {

	/// The status of this order
	var status: Status

	/// The timestamp after which the server will consider this order invalid, encoded in the format specified in [RFC3339].  This field is REQUIRED for objects with "pending" or "valid" in the status field.
	var expires: Date?

	/// An array of identifier objects that the order pertains to.
	var identifiers: [Identifier]

	/// The requested value of the notBefore field in the certificate, in the date format defined in [RFC3339].
	var notBefore: Date?

	/// The requested value of the notAfter field in the certificate, in the date format defined in [RFC3339].
	var notAfter: Date?

	/// The error that occurred while processing the order, if any.
	///
	/// This field is structured as a problem document [RFC7807].
	var error: ProblemDetails?

	/// For pending orders, the authorizations that the client needs to complete before the requested
	/// certificate can be issued (see Section 7.5), including unexpired authorizations that the client has
	/// completed in the past for identifiers specified in the order.
	///
	/// The authorizations required are dictated by server policy; there may not be a 1:1 relationship
	/// between the order identifiers and the authorizations required.
	/// For final orders (in the "valid" or "invalid" state), the authorizations that were completed.
	///
	/// Each entry is a URL from which an authorization can be fetched with a POST-as-GET request.
	var authorizations: [URL]

	/// A URL that a CSR must be POSTed to once all of the order's authorizations are satisfied to finalize the order.
	/// The result of a successful finalization will be the population of the certificate URL for the order.
	var finalize: URL

	/// A URL for the certificate that has been issued in response to this order.
	var certificate: URL?

	/// The status of an order.
	///
	/// https://datatracker.ietf.org/doc/html/rfc8555#section-7.1.6
	enum Status: String, Codable {
		case pending
		case ready
		case processing
		case valid
		case invalid
	}

	struct Identifier: Codable {
		enum `Type`: Codable {
			/// Any identifier of type "dns" in a newOrder request MAY have a
			/// wildcard domain name as its value.
			///
			/// A wildcard domain name consists
			/// of a single asterisk character followed by a single full stop
			/// character (`"*."`) followed by a domain name as defined for use in the
			/// Subject Alternate Name Extension by [RFC5280].  An authorization
			/// returned by the server for a wildcard domain name identifier MUST NOT
			/// include the asterisk and full stop (`"*."`) prefix in the authorization
			/// identifier value.
			///
			/// The returned authorization MUST include the
			/// optional "wildcard" field, with a value of true.
			case dns

			/// Catch-all for any types not yet known by this codebase.
			case unknown(String)

			func encode(to encoder: any Encoder) throws {
				var container = encoder.singleValueContainer()
				switch self {
				case .dns: try container.encode("dns")
				case var .unknown(value): try container.encode(value)
				}
			}

			init(from decoder: any Decoder) throws {
				let container = try decoder.singleValueContainer()
				let value = try container.decode(String.self)
				switch value {
					case "dns": self = .dns
					default: self = .unknown(value)
				}
			}
		}

		/// The type of identifier.
		///
		/// This document defines the "dns" identifier type.  See the registry defined in Section 9.7.7 for any others.
		var type: String

		/// The identifier itself.
		var value: String
	}
}
