import ACMEAPIModels
import FzkExtensions
import SwifterJSON
import Testing

struct ChallengeTests {
	@Test
	func decode__jsonContainsVariousFields__fieldsAreDeocdedCorrectly() async throws {
		let json = """
		{
			"status": "pending",
			"foo": 1,
			"bar": "baz",
			"array": [ 1, true, "foobar" ]
		}
		"""

		let challenge = try decode(json) as Challenge

		#expect(challenge.status == .pending)
		#expect(challenge.allFields.keys.sorted() == [
			"array",
			"bar",
			"foo",
			"status",
		])
		#expect(challenge.allFields == [
			"status": "pending",
			"foo": 1,
			"bar": "baz",
			"array": [ 1, true, "foobar" ]
		])
	}

	@Test(arguments: [
		(
			Challenge(status: .pending, allFields: [
				"status": JSON.string("pending"),
				"token": JSON.string("X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw"),
				"type": JSON.string("http-01"),
				"url": JSON.string("https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/z6xfyg"),
			]),
			"""
			CH:
			  status: "pending"
			  token: "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw"
			  type: "http-01"
			  url: "https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/z6xfyg"
			""",
		),
		(
			Challenge(status: .pending, allFields: [
				"url": JSON.string("https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/_oYs2Q"),
				"status": JSON.string("pending"),
				"token": JSON.string("X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw"),
				"type": JSON.string("dns-01"),
			]),
			"""
			CH:
			  status: "pending"
			  token: "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw"
			  type: "dns-01"
			  url: "https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/_oYs2Q"
			""",
		),
		(
			Challenge(status: .pending, allFields: [
				"token": JSON.string("X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw"),
				"status": JSON.string("pending"),
				"url": JSON.string("https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/fQZpoA"),
				"type": JSON.string("tls-alpn-01"),
			]),
			"""
			CH:
			  status: "pending"
			  token: "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw"
			  type: "tls-alpn-01"
			  url: "https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/fQZpoA"
			""",
		),
	])
	func description__letsEncryptDNSChallenge__outputIsFormatted(challenge: Challenge, expected: String) async throws {
		let actual = """
			CH:
			\(challenge, indentedWith: "  ")
			"""

		#expect(actual == expected)
	}
}
