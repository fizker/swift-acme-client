import Testing
import ACMEAPIModels
import CompileSafeInitMacro

struct NewAccountRequestTests {
	@Test
	func init__contactsIncludeMailtoScheme__initsCorrectly() async throws {
		let request = try NewAccountRequest(contact: [
			#URL("mailto:foo@example.com"),
		])

		#expect(request.contact == [
			#URL("mailto:foo@example.com"),
		])
	}

	@Test
	func init__contactsAreEmails_contactsAreWithoutScheme__initsCorrectly() async throws {
		let request = try NewAccountRequest(contact: [
			#URL("foo@example.com"),
		])

		#expect(request.contact == [
			#URL("mailto:foo@example.com"),
		])
	}

	@Test
	func init__contactsHaveNonEmailScheme__throws() async throws {
		#expect(throws: NewAccountRequest.ValidationError.contactMustBeEmail) {
			try NewAccountRequest(contact: [
				#URL("https://example.com"),
			])
		}
	}
}
