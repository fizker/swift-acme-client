import ACMEAPIModels
import CompileSafeInitMacro
import Foundation
import Testing

struct ChallengeTests {
	@Test
	func decodeFromJSON__multipleChallengeTypes__decodesCorrectly() async throws {
		let json = """
		[
			{
				"status": "pending",
				"foo": 1,
				"bar": "baz",
				"array": [ 1, true, "foobar" ]
			},
			{
				"status": "pending",
				"token": "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw",
				"type": "http-01",
				"url": "https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/z6xfyg"
			}
		]
		"""

		let actual = try decode(json) as [Challenge]

		#expect(actual == [
			.unknown(.init(
				status: .pending,
				allFields: [
					"status": "pending",
					"foo": 1,
					"bar": "baz",
					"array": [ 1, true, "foobar" ],
				],
			)),
			.letsEncrypt(.init(
				status: .pending,
				token: "X7l4LFRh_GRb4Nrq_Qum5i8kUP5ej1foHtPd9AmdaNw",
				type: .http,
				url: #URL("https://acme-staging-v02.api.letsencrypt.org/acme/chall/243411833/20483825683/z6xfyg"),
			))
		])
	}

	@Test
	func description__returnsTheInnerDescription() async throws {
		let generic = GenericChallenge(
			status: .processing,
			allFields: [
				"status": "processing",
				"foo": 1,
				"bar": "baz",
				"array": [ 1, true, "foobar" ],
			],
		)
		#expect("\(Challenge.unknown(generic))" == "\(generic)")

		let letsEncrypt = LetsEncryptChallenge(
			status: .valid,
			token: "foo",
			type: .dns,
			url: #URL("http://example.com"),
		)
		#expect("\(Challenge.letsEncrypt(letsEncrypt))" == "\(letsEncrypt)")
	}
}
