import CompileSafeInitMacro
import Foundation
import Testing
@testable import ACMEClient

struct DateModificationTests {
	@Test(arguments: [
		(#Date("2026-01-31T00:00:00Z"), Date.Modification.days(2), #Date("2026-02-02T00:00:00Z")),
		(#Date("2026-02-01T00:00:00Z"), Date.Modification.days(2), #Date("2026-02-03T00:00:00Z")),
		(#Date("2026-02-01T00:00:00Z"), Date.Modification.minutes(2), #Date("2026-02-01T00:02:00Z")),
		(#Date("2026-02-01T00:00:00Z"), Date.Modification.hours(2), #Date("2026-02-01T02:00:00Z")),
		(#Date("2026-02-01T00:00:00Z"), Date.Modification.seconds(10), #Date("2026-02-01T00:00:10Z")),
	])
	func adding__singleValue__addsExpected(input: Date, mod: Date.Modification, expected: Date) async throws {
		let actual = input.adding(mod)
		#expect(actual == expected)
	}

	@Test
	func adding__multipleValues__addsExpected() async throws {
		let input = #Date("2026-01-31T00:00:00Z")
		let expected = #Date("2026-01-31T10:05:00Z")
		let actual = input.adding(.hours(10), .minutes(5))
		#expect(actual == expected)
	}
}
