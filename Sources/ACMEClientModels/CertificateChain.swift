public import Foundation

public struct CertificateChain: Codable, Equatable, Hashable, Sendable {
	/// The certificates.
	public let certificates: [CertificateData]

	/// True if any of the certificates are self-signed.
	public let isSelfSigned: Bool

	/// The list of domains that the certificates covers.
	public let domains: Set<String>

	/// The date that the first certificate expires.
	public let expiresAt: Date

	public init(certificates: [CertificateData]) throws {
		guard !certificates.isEmpty
		else { throw Error.certificateChainCannotBeEmpty }

		self.certificates = certificates
		self.isSelfSigned = certificates.contains(where: \.isSelfSigned)
		self.domains = Set(certificates.flatMap(\.domains))
		self.expiresAt = certificates.map(\.expiresAt).min() ?? .now
	}

	public func covers(domains: [String]) -> Bool {
		check(certificateDomains: self.domains, covers: domains)
	}

	public enum Error: Swift.Error {
		case certificateChainCannotBeEmpty
	}
}
