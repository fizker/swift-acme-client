import CompileSafeInitMacro
import Foundation
import Testing
@testable import ACMEClient

struct DateHTTPDateTests {
	@Test(arguments: [
		("Sun, 06 Nov 1994 08:49:37 GMT", #Date("1994-11-06T08:49:37Z"), "IMF-fixdate"),
		("Sunday, 06-Nov-94 08:49:37 GMT", #Date("1994-11-06T08:49:37Z"), "obsolete RFC 850 format"),
		("Sun Nov  6 08:49:37 1994", #Date("1994-11-06T08:49:37Z"), "obsolete ANSI C's asctime() format"),
	])
	func initWithHTTPDate__examplesFromRFC__initsCorrectly(input: String, expected: Date, message: Comment) async throws {
		let actual = Date(httpDate: input)
		#expect(actual == expected, message)
	}

	@Test
	func initWithHTTPDate__relativeSeconds__initsCorrectly() async throws {
		let actual = Date(httpDate: "12345")
		let expected = Date.now.adding(.seconds(12345))
		#expect(actual == expected)
	}
}
