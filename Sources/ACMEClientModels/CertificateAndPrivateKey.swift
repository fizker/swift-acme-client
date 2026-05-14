public import Crypto
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

extension Certificate {
	static func generateSelfSigned(key: P256.Signing.PrivateKey = .init(), commonName: String, domains: Set<String>) throws -> Self {
		let subject = try DistinguishedName {
			CommonName(commonName)
		}
		let cert = try Certificate(
			version: .v3,
			serialNumber: .init(),
			publicKey: .init(key.publicKey),
			notValidBefore: .now,
			notValidAfter: Date(timeIntervalSinceNow: 3600 * 24 * 365),
			issuer: subject,
			subject: subject,
			signatureAlgorithm: .ecdsaWithSHA256,
			extensions: try .init(builder: {
				Critical(BasicConstraints.isCertificateAuthority(maxPathLength: nil))
				Critical(KeyUsage(digitalSignature: true, keyCertSign: true))
				SubjectAlternativeNames(domains.map {
					.dnsName($0)
				})
			}),
			issuerPrivateKey: .init(key)
		)

		return cert
	}
}

extension CertificateAndPrivateKey {
	public static func generateSelfSigned(key: P256.Signing.PrivateKey = .init(), commonName: String, domains: Set<String>) throws -> Self {
		let cert = try Certificate.generateSelfSigned(key: key, commonName: commonName, domains: domains)
		let chain = try CertificateChain(certificates: [ .init(domains: domains, certificate: cert, isSelfSigned: true) ])
		return Self(certificateChain: chain, privateKey: .init(key))
	}
}
