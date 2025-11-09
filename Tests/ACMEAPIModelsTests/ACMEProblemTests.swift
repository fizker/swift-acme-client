import Foundation
import Testing
@testable import ACMEAPIModels

struct ACMEProblemTests {
	@Test
	func decodeFrom__problemFromDocumentation__decodesCorrectly() async throws {
		let json = #"""
		{
		    "type": "urn:ietf:params:acme:error:malformed",
		    "detail": "Some of the identifiers requested were rejected",
		    "subproblems": [
		        {
		            "type": "urn:ietf:params:acme:error:malformed",
		            "detail": "Invalid underscore in DNS name \"_example.org\"",
		            "identifier": {
		                "type": "dns",
		                "value": "_example.org"
		            }
		        },
		        {
		            "type": "urn:ietf:params:acme:error:rejectedIdentifier",
		            "detail": "This CA will not issue for \"example.net\"",
		            "identifier": {
		                "type": "dns",
		                "value": "example.net"
		            }
		        }
		    ]
		}
		"""#

		let expected = ACMEProblem(
			type: .malformed,
			detail: "Some of the identifiers requested were rejected",
			subproblems: [
				.init(
					type: .malformed,
					detail: "Invalid underscore in DNS name \"_example.org\"",
					identifier: .init(type: .dns, value: "_example.org"),
				),
				.init(
					type: .rejectedIdentifier,
					detail: "This CA will not issue for \"example.net\"",
					identifier: .init(type: .dns, value: "example.net"),
				),
			],
		)

		let actual = try JSONDecoder().decode(ACMEProblem.self, from: json.data(using: .utf8)!)

		#expect(actual == expected)
	}
}
