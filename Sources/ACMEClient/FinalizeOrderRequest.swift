import Foundation
import SwiftASN1
import X509

struct FinalizeOrderRequest: Encodable {
	var csr: CertificateSigningRequest

	func encode(to encoder: any Encoder) throws {
		var serializer = DER.Serializer()
		try serializer.serialize(csr)

		let csrBytes = Data(serializer.serializedBytes)
		let pemStr = csrBytes.base64urlEncodedString()

		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(pemStr, forKey: .csr)
	}

	enum CodingKeys: String, CodingKey {
		case csr
	}
}
