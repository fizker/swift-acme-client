import ACMEAPIModels
@testable import ACMEClient
import CompileSafeInitMacro
import Crypto
import Foundation
import Testing

struct TypedAuthorizationTests {
	@Test
	func init__validHTTPChallenge__returnsHTTPChallenge() async throws {
		let privateKey = P256.PrivateKey()
		let identifier = Identifier(type: .dns, value: "example.com")
		let keyAuth = try KeyAuthorization(publicKey: privateKey.publicKey)

		let challenge = Challenge(
			status: .pending,
			token: "foo",
			type: .http,
			url: #URL("https://example.com"),
		)
		let auth = try TypedAuthorization(
			.init(
				identifier: identifier,
				status: .pending,
				challenges: [challenge],
			),
			url: #URL("https://auth.example.com/abc"),
			keyAuth: keyAuth,
		)

		let verification = try #require(auth.verify(via: .http))

		switch verification.challenge {
		case .dns:
			throw ChallengeError(message: "Challenge was DNS", type: verification.challenge.type)
		case .other:
			throw ChallengeError(message: "Challenge was other", type: verification.challenge.type)
		case .http:
			break
		}
	}

	@Test
	func init__validDNSChallenge__returnsDNSChallenge() async throws {
		let privateKey = P256.PrivateKey()
		let identifier = Identifier(type: .dns, value: "example.com")
		let keyAuth = try KeyAuthorization(publicKey: privateKey.publicKey)

		let challenge = Challenge(
			status: .pending,
			token: "foo",
			type: .dns,
			url: #URL("https://example.com"),
		)
		let auth = try TypedAuthorization(
			.init(
				identifier: identifier,
				status: .pending,
				challenges: [challenge],
			),
			url: #URL("https://auth.example.com/abc"),
			keyAuth: keyAuth,
		)

		let verification = try #require(auth.verify(via: .dns))

		switch verification.challenge {
		case .dns:
			break
		case .other:
			throw ChallengeError(message: "Challenge was other", type: verification.challenge.type)
		case .http:
			throw ChallengeError(message: "Challenge was HTTP", type: verification.challenge.type)
		}
	}

	struct ChallengeError: Error {
		var message: String
		var type: Challenge.`Type`
	}
}
