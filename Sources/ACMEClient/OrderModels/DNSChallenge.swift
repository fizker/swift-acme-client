public import ACMEAPIModels
public import Crypto
public import Foundation

public struct DNSChallenge: CustomStringConvertible {
	public let url: URL
	public let token: String
	public var type: Challenge.`Type` { .dns }
	public let identifier: Identifier

	public let txt: TXT

	init(_ challenge: Challenge, identifier: Identifier, keyAuth: KeyAuthorization) throws {
		guard challenge.type == .dns
		else { throw CustomError(message: "Non-DNS challenge passed: \(challenge.type)") }

		self.identifier = identifier
		url = challenge.url
		token = challenge.token

		let domain = identifier.value
		let txtDomain = if domain.hasPrefix("*") {
			"_acme-challenge\(domain[domain.index(after: domain.startIndex)...])"
		} else {
			"_acme-challenge.\(domain)"
		}

		txt = TXT(
			domain: txtDomain,
			value: keyAuth.digest(for: challenge),
		)
	}

	/// The directions for how to pass this challenge.
	public var directions: String {
		"""
		For \(identifier.value), add a TXT record at \(txt.domain) containing:
		- \(txt.value.base64urlEncodedString())
		- Token: \(token)
		"""
	}

	public var description: String {
		"DNS: \(directions)"
	}

	public struct TXT {
		public let domain: String
		public let value: SHA256Digest
	}
}
