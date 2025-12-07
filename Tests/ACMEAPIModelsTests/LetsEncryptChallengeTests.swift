import ACMEAPIModels
import CompileSafeInitMacro
import Foundation
import FzkExtensions
import SwifterJSON
import Testing

struct LetsEncryptChallengeTests {
	@Test(arguments: testData.map { ($0.json, $0.challenge) })
	func decodeFromJSON__decodesCorrectly(json: String, expected: LetsEncryptChallenge) async throws {
		let actual = try decode(json) as LetsEncryptChallenge
		#expect(actual == expected)
	}

	@Test(arguments: testData.map { ($0.challenge, $0.description) })
	func description__outputIsFormatted(challenge: LetsEncryptChallenge, expected: String) async throws {
		let actual = """
			CH:
			\(challenge, indentedWith: "  ")
			"""

		#expect(actual == expected)
	}

	static let testData: [(challenge: LetsEncryptChallenge, description: String, json: String)] = [
		(
			LetsEncryptChallenge(
				status: .pending,
				token: "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw",
				type: .http,
				url: #URL("https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/z6xfyg"),
			),
			"""
			CH:
			  status: "pending"
			  token: "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw"
			  type: "http-01"
			  url: "https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/z6xfyg"
			""",
			"""
			{
			    "status": "pending",
			    "token": "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw",
			    "type": "http-01",
			    "url": "https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/z6xfyg"
			}
			""",
		),
		(
			LetsEncryptChallenge(
				status: .pending,
				token: "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw",
				type: .dns,
				url: #URL("https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/_oYs2Q"),
			),
			"""
			CH:
			  status: "pending"
			  token: "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw"
			  type: "dns-01"
			  url: "https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/_oYs2Q"
			""",
			"""
			{
			  "status": "pending",
			  "token": "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw",
			  "type": "dns-01",
			  "url": "https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/_oYs2Q"
			}
			""",
		),
		(
			LetsEncryptChallenge(
				status: .pending,
				token: "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw",
				type: .tlsALPN,
				url: #URL("https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/fQZpoA"),
			),
			"""
			CH:
			  status: "pending"
			  token: "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw"
			  type: "tls-alpn-01"
			  url: "https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/fQZpoA"
			""",
			"""
			{
			  "status": "pending",
			  "token": "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw",
			  "type": "tls-alpn-01",
			  "url": "https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/fQZpoA"
			}
			""",
		),
	]
}
