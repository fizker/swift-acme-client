import ACMEAPIModels
import Crypto
import Foundation

struct DNSChallenge: CustomStringConvertible {
	var url: URL
	var token: String
	var type: Challenge.`Type` { .dns }
	var identifier: Identifier

	var txt: TXT

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
	var directions: String {
		"""
		For \(identifier.value), add a TXT record at \(txt.domain) containing:
		- \(txt.value.base64urlEncodedString())
		- Token: \(token)
		"""
	}

	var description: String {
		"DNS: \(directions)"
	}

	struct TXT {
		var domain: String
		var value: SHA256Digest
	}
}
