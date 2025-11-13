import Testing
@testable import ACMEAPIModels

struct ErrorTypeTests {
	@Test(arguments: [
		("urn:ietf:params:acme:error:accountDoesNotExist", ErrorType.accountDoesNotExist),
		("urn:ietf:params:acme:error:badPublicKey", ErrorType.badPublicKey),
		("urn:ietf:params:acme:error:rejectedIdentifier", ErrorType.rejectedIdentifier),
		("urn:ietf:params:acme:error:unknownValue", ErrorType.unknown("unknownValue")),
	])
	func initWithRawValue__validValues__parsesAsExpected(raw: String, expected: ErrorType) async throws {
		let actual = ErrorType(rawValue: raw)
		#expect(actual == expected)
	}

	@Test(arguments: [
		"foobar",
		"urn:ietf:params:acme:errorunknownValue",
	])
	func initWithRawValue__invalidValue__returnsNil(raw: String) async throws {
		#expect(ErrorType(rawValue: raw) == nil)
	}
}
