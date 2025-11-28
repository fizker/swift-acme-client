import ACMEAPIModels
import SwifterJSON
import Testing

struct ChallengeTests {
	@Test
	func decode__jsonContainsVariousFields__fieldsAreDeocdedCorrectly() async throws {
		let json = """
		{
			"status": "pending",
			"foo": 1,
			"bar": "baz",
			"array": [ 1, true, "foobar" ]
		}
		"""

		let challenge = try decode(json) as Challenge

		#expect(challenge.status == .pending)
		#expect(challenge.allFields.keys.sorted() == [
			"array",
			"bar",
			"foo",
			"status",
		])
		#expect(challenge.allFields == [
			"status": "pending",
			"foo": 1,
			"bar": "baz",
			"array": [ 1, true, "foobar" ]
		])
	}
}
