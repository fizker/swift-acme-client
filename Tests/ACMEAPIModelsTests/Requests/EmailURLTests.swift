import Testing
import ACMEAPIModels
import CompileSafeInitMacro
import Foundation

struct EmailURLTests {
	@Test(arguments: [
		("mailto:foo@example.com", #URL("mailto:foo@example.com")),
		("foo@example.com", #URL("mailto:foo@example.com")),
	])
	func init__validValue(value: String, expectedValue: URL) async throws {
		#expect(try EmailURL("mailto:foo@example.com").url == expectedValue)
	}

	@Test(arguments: [
		"https://example.com",
		"mailto://example.com",
	])
	func init__invalidValue(value: String) async throws {
		#expect(throws: EmailURL.ValidationError.contactMustBeEmail) {
			try EmailURL("https://example.com")
		}
	}
}
