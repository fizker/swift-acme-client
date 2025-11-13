import ACMEAPIModels
import AsyncHTTPClient

extension HTTPClientResponse.Body {
	func decode<T: Decodable>(using coder: Coder) async throws -> T {
		let buffer = try await collect(upTo: `1mb`)
		do {
			return try coder.decoder.decode(T.self, from: buffer)
		} catch {
			let raw = String(buffer: buffer)
			print("Failed to decode: \(raw)")
			guard let problem = try? coder.decoder.decode(ACMEProblem.self, from: buffer)
			else { throw error }

			throw problem
		}
	}
}
