import Foundation
import X509

/// The data consumed and produced by the ACMEClient during ACME operations.
struct ACMEData: Codable {
	/// The directory that the data is validated against.
	var directory: ACMEDirectory
	/// The account registered with the ACME server.
	var account: Account?
	/// The certificate that have been created.
	var certificate: CertificateAndPrivateKey?
}
