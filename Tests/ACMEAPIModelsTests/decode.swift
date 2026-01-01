import Foundation

func decode<T: Decodable>(_ json: String) throws -> T {
	let data = json.data(using: .utf8)!
	return try JSONDecoder().decode(T.self, from: data)
}
