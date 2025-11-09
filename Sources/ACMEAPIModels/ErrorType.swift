/// https://datatracker.ietf.org/doc/html/rfc8555#section-6.7
public enum ErrorType: Codable, Equatable, Sendable {
	/// The request specified an account that does not exist
	case accountDoesNotExist

	/// The request specified a certificate to be revoked that has already been revoked
	case alreadyRevoked

	/// The CSR is unacceptable (e.g., due to a short key)
	case badCSR

	/// The client sent an unacceptable anti-replay nonce
	case badNonce

	/// The JWS was signed by a public key the server does not support
	case badPublicKey

	/// The revocation reason provided is not allowed by the server
	case badRevocationReason

	/// The JWS was signed with an algorithm the server does not support
	case badSignatureAlgorithm

	/// Certification Authority Authorization (CAA) records forbid the CA from issuing a certificate
	case caa

	/// Specific error conditions are indicated in the "subproblems" array
	case compound

	/// The server could not connect to validation target
	case connection

	/// There was a problem with a DNS query during identifier validation
	case dns

	/// The request must include a value for the "externalAccountBinding" field
	case externalAccountRequired

	/// Response received didn't match the challenge's requirements
	case incorrectResponse

	/// A contact URL for an account was invalid
	case invalidContact

	/// The request message was malformed
	case malformed

	/// The request attempted to finalize an order that is not ready to be finalized
	case orderNotReady

	/// The request exceeds a rate limit
	case rateLimited

	/// The server will not issue certificates for the identifier
	case rejectedIdentifier

	/// The server experienced an internal error
	case serverInternal

	/// The server received a TLS error during validation
	case tls

	/// The client lacks sufficient authorization
	case unauthorized

	/// A contact URL for an account used an unsupported protocol scheme
	case unsupportedContact

	/// An identifier is of an unsupported type
	case unsupportedIdentifier

	/// Visit the "instance" URL and take actions specified there
	case userActionRequired

	case unknown(String)
}

extension ErrorType: RawRepresentable {
	private static var base: String { "urn:ietf:params:acme:error:" }

	public var rawValue: String {
		let code: String

		switch self {
		case .accountDoesNotExist: code = "accountDoesNotExist"
		case .alreadyRevoked: code = "alreadyRevoked"
		case .badCSR: code = "badCSR"
		case .badNonce: code = "badNonce"
		case .badPublicKey: code = "badPublicKey"
		case .badRevocationReason: code = "badRevocationReason"
		case .badSignatureAlgorithm: code = "badSignatureAlgorithm"
		case .caa: code = "caa"
		case .compound: code = "compound"
		case .connection: code = "connection"
		case .dns: code = "dns"
		case .externalAccountRequired: code = "externalAccountRequired"
		case .incorrectResponse: code = "incorrectResponse"
		case .invalidContact: code = "invalidContact"
		case .malformed: code = "malformed"
		case .orderNotReady: code = "orderNotReady"
		case .rateLimited: code = "rateLimited"
		case .rejectedIdentifier: code = "rejectedIdentifier"
		case .serverInternal: code = "serverInternal"
		case .tls: code = "tls"
		case .unauthorized: code = "unauthorized"
		case .unsupportedContact: code = "unsupportedContact"
		case .unsupportedIdentifier: code = "unsupportedIdentifier"
		case .userActionRequired: code = "userActionRequired"
		case let .unknown(code_): code = code_
		}

		return Self.base + code
	}

	public init?(rawValue: String) {
		guard rawValue.hasPrefix(Self.base)
		else { return nil }

		let code = String(rawValue[Self.base.endIndex...])
		switch code {
		case "accountDoesNotExist": self = .accountDoesNotExist
		case "alreadyRevoked": self = .alreadyRevoked
		case "badCSR": self = .badCSR
		case "badNonce": self = .badNonce
		case "badPublicKey": self = .badPublicKey
		case "badRevocationReason": self = .badRevocationReason
		case "badSignatureAlgorithm": self = .badSignatureAlgorithm
		case "caa": self = .caa
		case "compound": self = .compound
		case "connection": self = .connection
		case "dns": self = .dns
		case "externalAccountRequired": self = .externalAccountRequired
		case "incorrectResponse": self = .incorrectResponse
		case "invalidContact": self = .invalidContact
		case "malformed": self = .malformed
		case "orderNotReady": self = .orderNotReady
		case "rateLimited": self = .rateLimited
		case "rejectedIdentifier": self = .rejectedIdentifier
		case "serverInternal": self = .serverInternal
		case "tls": self = .tls
		case "unauthorized": self = .unauthorized
		case "unsupportedContact": self = .unsupportedContact
		case "unsupportedIdentifier": self = .unsupportedIdentifier
		case "userActionRequired": self = .userActionRequired
		default: self = .unknown(code)
		}
	}
}
