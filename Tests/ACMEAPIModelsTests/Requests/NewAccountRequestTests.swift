import Testing
import ACMEAPIModels
import CompileSafeInitMacro
import Foundation

struct NewAccountRequestTests {
	@Test
	func encode__singleEmail_termsAccepted__encodesCorrectly() async throws {
		let request = try NewAccountRequest(
			contact: "foo@example.com",
			termsOfServiceAgreed: true,
		)

		let actual = try encode(request)
		#expect(actual == """
		{
		  "contact" : [
		    "mailto:foo@example.com"
		  ],
		  "termsOfServiceAgreed" : true
		}
		""")
	}
}
