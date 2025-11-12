public import ACMEAPIModels
public import ACMEClientModels
import AsyncHTTPClient
import Foundation
import FzkExtensions
import NIOFoundationCompat

let `1mb` = 1024 * 1024

struct Coder {
	var decoder = JSONDecoder()
	var encoder = JSONEncoder()
}

public actor ACMEClient {
	let coder = Coder()
	let directory: Directory
	let httpClient: HTTPClient

	public init(directory: ACMEDirectory) async throws {
		httpClient = .shared

		let request = HTTPClientRequest(url: directory.rawValue.absoluteString)
		let response = try await httpClient.execute(request, timeout: .seconds(30))
		self.directory = try await response.body.decode(using: coder)
	}

	public func account() async throws -> Account {
		let locationResponse = try await post(value: ExistingAccountRequest(), to: directory.newAccount)

		guard locationResponse.status == .ok || locationResponse.status == .noContent
		else {
			let problem = try await locationResponse.body.decode(using: coder) as ACMEProblem
			throw problem
		}

		guard let accountURL = locationResponse.headers.first(name: "location").flatMap(URL.init(string:))
		else {
			fatalError()
		}

		return try await get(from: accountURL)
	}

	func get<T: Decodable>(type: T.Type = T.self, from url: URL) async throws -> T {
		let request = HTTPClientRequest(url: url)
		let response = try await httpClient.execute(request, timeout: .seconds(30))

		return try await response.body.decode(using: coder)
	}

	func post(value: some Encodable, to url: URL) async throws -> HTTPClientResponse {
		let request = try HTTPClientRequest(url: directory.newAccount) ~ {
			$0.method = .POST
			let data = try coder.encoder.encode(value)
			$0.body = .bytes(data)
		}

		let response = try await httpClient.execute(request, timeout: .seconds(30))
		guard response.status.isSuccess
		else {
			let problem = try await response.body.decode(using: coder) as ACMEProblem
			throw problem
		}

		return response
	}
}
