public import Foundation
public import X509

/// A convenience bundle for storing a ``CertificateChain`` along side the private key used to create the certificates.
public struct CertificateAndPrivateKey: Codable, Equatable, Hashable, Sendable {
	/// The certificates.
	public var certificateChain: CertificateChain
	/// The private key used to create the certificates.
	public var privateKey: Certificate.PrivateKey

	/// Creates a new cert-chain-and-private-key bundle.
	public init(certificateChain: CertificateChain, privateKey: Certificate.PrivateKey) {
		self.certificateChain = certificateChain
		self.privateKey = privateKey
	}

	/// Returns `true` if the certificates in the chain covers all of the domains given.
	///
	/// It will also be true if a combination of the certificates is required for full coverage. For example,
	/// if two certificates are in the chain covering one domain each, then the chain is considered to cover
	/// both those domains.
	public func covers(domains: [String]) -> Bool {
		certificateChain.covers(domains: domains)
	}

	/// The date that the first certificate expires.
	public var expiresAt: Date { certificateChain.expiresAt }
}
