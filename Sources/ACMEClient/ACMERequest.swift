import ACMEAPIModels
import ACMEClientModels
import Crypto
import Foundation
import JWTKit

struct ACMERequest: Encodable {
	let url: URL

	enum CodingKeys: String, CodingKey {
		case header = "protected"
		case payload
		case signature
	}

	fileprivate var header: String
	fileprivate var payload: String
	fileprivate var signature: String

	init(url: URL, nonce: Nonce, accountKey: Key.Private, accountURL: URL?, body: SpecialCases) throws {
		let body: Data? = switch body {
		case .emptyBody: "{}".data(using: .utf8)!
		case .getAsPost: nil
		}

		try self.init(
			url: url,
			nonce: nonce,
			accountKey: accountKey,
			accountURL: accountURL,
			body: body,
		)
	}

	init(url: URL, nonce: Nonce, accountKey: Key.Private, accountURL: URL?, body: (some Encodable)) throws {
		try self.init(
			url: url,
			nonce: nonce,
			accountKey: accountKey,
			accountURL: accountURL,
			body: try coder.encoder.encode(body) as Data?,
		)
	}

	private init(url: URL, nonce: Nonce, accountKey: Key.Private, accountURL: URL?, body: Data?) throws {
		self.url = url

		header =  try coder.encoder.encode(ProtectedHeader(
			alg: "ES256",
			nonce: nonce,
			url: url,
			kid: accountURL,
			jwk: accountURL == nil ? .ecdsa(publicKey: accountKey.publicKey) : nil,
		)).base64urlEncodedString()
		payload = body?.base64urlEncodedString() ?? ""
		let sign = "\(header).\(payload)"
		signature = try accountKey.signature(for: Data(sign.utf8)).rawRepresentation.base64urlEncodedString()
	}

	enum SpecialCases {
		case getAsPost
		case emptyBody
	}
}

extension JWK {
	static func ecdsa(publicKey: P256.Signing.PublicKey) -> JWK {
		let publicKey = publicKey.rawRepresentation
		return JWK.ecdsa(
			nil,
			identifier: nil,
			x: publicKey.prefix(publicKey.count/2).base64urlEncodedString(),
			y: publicKey.suffix(publicKey.count/2).base64urlEncodedString(),
			curve: .p256,
		)
	}
}

private struct ProtectedHeader: Codable {
	var alg: String
	var nonce: String
	var url: URL
	var kid: URL?
	var jwk: JWK?
}
