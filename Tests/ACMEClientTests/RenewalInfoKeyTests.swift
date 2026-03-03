import Testing
@testable import ACMEClient

struct RenewalInfoKeyTests {
	@Test
	func init__valuesFromRFC__createsExpectedValue() async throws {
		let ki = makeByteArray(from: "69:88:5B:6B:87:46:40:41:E1:B3:7B:84:7B:A0:AE:2C:DE:01:C8:D4")
		let sn = makeByteArray(from: "00:87:65:43:21")
		let key = RenewalInfoKey(keyIdentifier: ki, serialNumber: sn)

		#expect(key.value == "aYhba4dGQEHhs3uEe6CuLN4ByNQ.AIdlQyE")
	}

	@Test(arguments: [
		("a2", [0xa2]),
		("a2:b1", [0xa2, 0xb1]),
	])
	func makeByteArray__correctlyConvertsToHex(input: String, expected: [UInt8]) async throws {
		#expect(Array(makeByteArray(from: input)) == expected)
	}

	func makeByteArray(from hexString: String) -> some Sequence<UInt8> {
		return hexString.split(separator: ":").map { UInt8($0, radix: 16) }.compacted()
	}
}
