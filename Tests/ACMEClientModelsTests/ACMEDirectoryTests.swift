import Foundation
import CompileSafeInitMacro
import Testing

import ACMEClientModels

struct ACMEDirectoryTests {
	@Test(arguments: [
		(ACMEDirectory.letsEncryptV2Production, ACMEDirectory.letsEncryptV2Production, true),
		(.letsEncryptV2Staging, .letsEncryptV2Staging, true),
		(.letsEncryptV2Production, .letsEncryptV2Staging, false),
	])
	func equals__predefinedURLsUsed__propertiesAreEqual(lhs: ACMEDirectory, rhs: ACMEDirectory, expected: Bool) async throws {
		let actual = lhs == rhs
		#expect(actual == expected)
	}

	@Test(arguments: [
		(#URL("http://example.com"), #URL("http://example.com"), true),
		(#URL("http://example.com"), #URL("http://other.example.com"), false),
	])
	func equals__customURL__returnsEqualIfURLSAreEqual(lhs: URL, rhs: URL, expected: Bool) async throws {
		let actual = ACMEDirectory.custom(lhs) == .custom(rhs)
		#expect(actual == expected)
	}

	@Test
	func equals__predefinedURLWithMatchingCustomURL__returnsTrue() async throws {
		let lhs = ACMEDirectory.letsEncryptV2Production
		let rhs = ACMEDirectory.custom(lhs.rawValue)
		let actual = lhs == rhs
		#expect(actual == true)
	}
}
