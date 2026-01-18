import ACMEAPIModels
import Foundation

func decode<T: Decodable>(_ json: String) throws -> T {
	let data = json.data(using: .utf8)!
	return try apiCoder.decode(data)
}

func encode(_ encodable: some Encodable) throws -> String {
	let data = try apiCoder.encode(encodable)
	return String(data: data, encoding: .utf8)!
}
