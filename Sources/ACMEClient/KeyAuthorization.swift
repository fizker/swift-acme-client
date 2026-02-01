import ACMEAPIModels
import Crypto
import Foundation
import JWTKit

package struct KeyAuthorization {
	var publicKey: P256.PrivateKey.PublicKey
	var thumbprint: String

	init(publicKey: P256.PrivateKey.PublicKey) throws {
		self.publicKey = publicKey
		thumbprint = Data(try JWK.thumbprint(of: publicKey)).base64urlEncodedString()
	}

	func value(for challenge: Challenge) -> String {
		"\(challenge.token).\(thumbprint)"
	}

	func digest(for challenge: Challenge) -> SHA256Digest {
		SHA256.hash(data: value(for: challenge).data(using: .utf8)!)
	}
}

extension JWK {
	static func thumbprint(of key: P256.Signing.PublicKey) throws -> SHA256Digest {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [.sortedKeys]

		let jwk = JWK.ecdsa(publicKey: key)
		let data = try encoder.encode(jwk)
		return SHA256.hash(data: data)
	}
}
