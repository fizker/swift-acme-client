import ACMEAPIModels
import AsyncHTTPClient
import Foundation
import FzkExtensions

struct API {
	let httpClient: HTTPClient
	let directory: Directory

	func fetchNonce() async throws -> Nonce {
		let request = HTTPClientRequest(url: directory.newNonce) ~ {
			$0.method = .HEAD
		}

		let response = try await httpClient.execute(request, timeout: .seconds(30))

		return try response.nonce
	}

	func fetchAccountURL(nonce: Nonce, accountKey: Key.Private) async throws -> (URL?, Nonce) {
		let response = try await post(try ACMERequest(
			url: directory.newAccount,
			nonce: nonce,
			accountKey: accountKey,
			accountURL: nil,
			body: ExistingAccountRequest(),
		))

		guard response.status.isSuccess
		else {
			let problem = try await response.body.decode(using: coder) as ACMEProblem
			throw problem
		}

		let accountURL = response.headers.first(name: "location").flatMap(URL.init(string:))

		return (accountURL, try response.nonce)
	}

	private func post(_ acmeRequest: ACMERequest) async throws -> HTTPClientResponse {
		var request = HTTPClientRequest(url: acmeRequest.url)
		request.method = .POST
		let data = try coder.encoder.encode(acmeRequest)
		request.body = .bytes(data)

		return try await httpClient.execute(request, timeout: .seconds(30))
	}
}

extension HTTPClientResponse {
	var nonce: Nonce {
		get throws {
			guard let nonce = headers["replay-nonce"].first
			else { throw ACMEError.nonceMissing }

			return nonce
		}
	}
}
