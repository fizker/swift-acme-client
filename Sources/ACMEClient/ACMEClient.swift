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
		let locationRequest = try HTTPClientRequest(url: directory.newAccount.absoluteString) ~ {
			$0.method = .POST
			let data = try coder.encoder.encode(ExistingAccountRequest())
			$0.body = .bytes(data)
		}

		let locationResponse = try await httpClient.execute(locationRequest, timeout: .seconds(30))
		guard locationResponse.status == .ok || locationResponse.status == .noContent
		else {
			let problem = try await locationResponse.body.decode(using: coder) as ACMEProblem
			throw problem
		}

		guard let accountURL = locationResponse.headers.first(name: "location")
		else {
			fatalError()
		}

		let accountRequest = HTTPClientRequest(url: accountURL)
		let accountResponse = try await httpClient.execute(accountRequest, timeout: .seconds(30))

		return try await accountResponse.body.decode(using: coder)
	}
}

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
