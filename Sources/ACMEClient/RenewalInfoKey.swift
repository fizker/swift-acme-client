import ACMEAPIModels
import ACMEClientModels
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

extension ACMEClientModels.RenewalInfo {
	init(_ info: ACMEAPIModels.RenewalInfo, recommendedDateForNextCheck: Date, certificateIdentifier: String) {
		self.init(
			suggestedWindow: .init(start: info.suggestedWindow.start, end: info.suggestedWindow.end),
			recommendedDateForNextCheck: min(
				recommendedDateForNextCheck,
				info.suggestedWindow.randomTime,
				.now.adding(.days(1)),
			),
			explanationURL: info.explanationURL,
		)
		self.certificateIdentifier = certificateIdentifier
	}

	init(_ certificate: CertificateAndPrivateKey) {
		let windowStart = certificate.expiresAt.adding(.days(-15))
		self.init(
			suggestedWindow: .init(start: windowStart, end: windowStart.adding(.days(2))),
			recommendedDateForNextCheck: min(certificate.expiresAt, .now.adding(.days(1))),
		)
	}
}
