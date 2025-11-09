public import ACMEAPIModels
public import ACMEClientModels
import AsyncHTTPClient
import Foundation
import NIOFoundationCompat

let `1mb` = 1024 * 1024

struct Coder {
	var decoder = JSONDecoder()
}

public actor ACMEClient {
	let coder = Coder()
	let directory: Directory
	let httpClient: HTTPClient

	public init(directory: ACMEDirectory) async throws {
		httpClient = .shared

		let request = HTTPClientRequest(url: directory.rawValue.absoluteString)
		let response = try await httpClient.execute(request, timeout: .seconds(30))
		let body = try await response.body.collect(upTo: `1mb`)

		self.directory = try coder.decoder.decode(Directory.self, from: body)
	}

	public func account() async throws -> Account {
		fatalError()
	}
}
