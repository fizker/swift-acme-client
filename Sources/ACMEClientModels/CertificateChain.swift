public import Foundation

/// A chain of created certificates.
///
/// This will typically cover all certificates created by a ACME order.
public struct CertificateChain: Codable, Equatable, Hashable, Sendable {
	/// The certificates.
	public let certificates: [CertificateData]

	/// True if any of the certificates are self-signed.
	public let isSelfSigned: Bool

	/// The list of domains that the certificates covers.
	public let domains: Set<String>

	/// The date that the first certificate expires.
	public let expiresAt: Date

	/// Creates a new certificate chain containing the given certificates.
	///
	/// - parameter certificates: The certificates in the chain. This sequence must be non-empty.
	/// - throws: If no certificates are given, ``CertificateChainCannotBeEmptyError`` is thrown.
	public init(certificates: some Sequence<CertificateData>) throws(CertificateChainCannotBeEmptyError) {
		self.certificates = .init(certificates)

		guard !self.certificates.isEmpty
		else { throw CertificateChainCannotBeEmptyError() }

		self.isSelfSigned = certificates.contains(where: \.isSelfSigned)
		self.domains = Set(certificates.flatMap(\.domains))
		self.expiresAt = certificates.map(\.expiresAt).min() ?? .now
	}

	/// Returns `true` if the certificates in the chain covers all of the domains given.
	///
	/// It will also be true if a combination of the certificates is required for full coverage. For example,
	/// if two certificates are in the chain covering one domain each, then the chain is considered to cover
	/// both those domains.
	public func covers(domains: [String]) -> Bool {
		check(certificateDomains: self.domains, covers: domains)
	}

	/// The error thrown if the chain is attempted to be created with no certificates.
	public struct CertificateChainCannotBeEmptyError: Error {
	}
}
