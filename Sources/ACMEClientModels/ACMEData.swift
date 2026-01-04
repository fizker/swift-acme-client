import Foundation
import X509

/// The data consumed and produced by the ACMEClient during ACME operations.
public struct ACMEData: Codable, Sendable {
	/// The directory that the data is validated against.
	public var directory: ACMEDirectory
	/// The account registered with the ACME server.
	public var account: Account?
	/// The certificate that have been created.
	public var certificate: CertificateAndPrivateKey?

	public init(directory: ACMEDirectory, account: Account? = nil, certificate: CertificateAndPrivateKey? = nil) {
		self.directory = directory
		self.account = account
		self.certificate = certificate
	}
}
