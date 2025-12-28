import ACMEAPIModels
import CompileSafeInitMacro
import Crypto
import Foundation
import Testing
@testable import ACMEClient

struct KeyAuthorizationTests {
	let privateKey = """
	-----BEGIN PRIVATE KEY-----
	MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgOjWLANtlSuTNbU8M
	XrQeY6Gb4zdL3HkStMB7M0Yzi56hRANCAARZIAf2HJUEMDa6G+lDgg11kXhjsARZ
	D3fynNuUUHJTsm6VeVlZSkfiAkdyuw8GRplIefxZCwrELxlqEC1YJT6h
	-----END PRIVATE KEY-----
	"""

	@Test
	func digestForChallenge__validPrivateKey__challengeIsCorrectlyDigested() async throws {
		let subject = try KeyAuthorization(publicKey: P256.PrivateKey(pemRepresentation: privateKey).publicKey)
		let challenge = Challenge(
			status: .pending,
			token: "oOLvKGj8lFT5aG10plZzTxJzE_UNroEOoNcz3M0VOl8",
			type: .dns,
			url: #URL("fizkerinc.dk"),
		)
		#expect(subject.digest(for: challenge).base64urlEncodedString() == "KeEg-nXWT5o81d_qLoEtExX5cNzT-KRi0N5xSrOM0ws")
	}
}
