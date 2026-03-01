import Foundation
import X509

struct RenewalInfoKey {
	typealias ByteArray = Sequence<UInt8>
	init(for certificate: Certificate) throws(AuthorityKeyIdentifierNotFoundError) {
		guard
			let aki = try? certificate.extensions.authorityKeyIdentifier,
			let ki = aki.keyIdentifier
		else { throw AuthorityKeyIdentifierNotFoundError() }

		self.init(keyIdentifier: ki, serialNumber: certificate.serialNumber.bytes)
	}

	init(keyIdentifier: some ByteArray, serialNumber: some ByteArray) {
		value = "\(keyIdentifier.base64urlEncodedString()).\(serialNumber.base64urlEncodedString())"
	}

	let value: String

	struct AuthorityKeyIdentifierNotFoundError: Error {
	}
}
