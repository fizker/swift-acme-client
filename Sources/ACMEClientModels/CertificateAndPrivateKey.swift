public import Foundation
public import X509

public struct CertificateAndPrivateKey: Codable, Equatable, Hashable {
	/// The certificates.
	public var certificateChain: CertificateChain
	/// The private key used to create the certificates.
	public var privateKey: Certificate.PrivateKey

	public init(certificateChain: CertificateChain, privateKey: Certificate.PrivateKey) {
		self.certificateChain = certificateChain
		self.privateKey = privateKey
	}

	public func covers(domains: [String]) -> Bool {
		certificateChain.covers(domains: domains)
	}

	/// The date that the first certificate expires.
	public var expiresAt: Date { certificateChain.expiresAt }
}
