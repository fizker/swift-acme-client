import ACMEAPIModels
import AsyncHTTPClient
import NIOCore

extension HTTPClientResponse.Body {
	func decode<T: Decodable>(using coder: APICoder) async throws -> T {
		let buffer = try await collect(upTo: `1mb`)
		do {
			return try coder.decode(buffer)
		} catch {
			let raw = String(buffer: buffer)
			print("Failed to decode: \(raw)")
			guard let problem = try? coder.decode(buffer) as ACMEProblem
			else { throw error }

			throw problem
		}
	}
}
