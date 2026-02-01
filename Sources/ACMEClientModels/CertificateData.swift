public import Foundation
public import X509

/// A certificate and some additional metadata.
public struct CertificateData: Codable, Equatable, Hashable, Sendable {
	/// The certificate.
	public let certificate: Certificate

	/// True if the certificate is self-signed.
	public let isSelfSigned: Bool

	/// The list of domains that the certificate covers.
	public let domains: Set<String>

	/// The date that the certificate expires.
	public var expiresAt: Date { certificate.notValidAfter }

	/// Creates a certificate data bundle with the given data.
	public init(domains: some Sequence<String>, certificate: Certificate, isSelfSigned: Bool) {
		self.domains = .init(domains)
		self.certificate = certificate
		self.isSelfSigned = isSelfSigned
	}

	/// Returns `true` if the certificate covers all of the domains given.
	public func covers(domains: [String]) -> Bool {
		check(certificateDomains: self.domains, covers: domains)
	}
}

extension CertificateData {
	/// Creates a certificate data bundle by attempting to extract the domains covered by examining the
	/// `SubjectAlternativeNames` extension.
	///
	/// - throws: This will throw if there is no `SubjectAlternativeNames`.
	public init(certificate: Certificate, isSelfSigned: Bool) throws {
		let domains = try certificate.extensions.subjectAlternativeNames?.compactMap { altName -> String? in
			switch altName {
			case .otherName(_):
				nil
			case .rfc822Name(_):
				nil
			case let .dnsName(domain):
				domain
			case .x400Address(_):
				nil
			case .directoryName(_):
				nil
			case .ediPartyName(_):
				nil
			case .uniformResourceIdentifier(_):
				nil
			case .ipAddress(_):
				nil
			case .registeredID(_):
				nil
			}
		}

		self.init(domains: domains ?? [], certificate: certificate, isSelfSigned: isSelfSigned)
	}

	/// Creates a certificate data bundle by unpacking the given PEM encoded string and attempting to
	/// read the affected domains from the resulting certificate.
	///
	/// - throws: This will throw if the string could not be decoded or if the resulting certificate does not
	///   have the `SubjectAlternativeNames` extension.
	public init(pemEncoded: String, isSelfSigned: Bool) throws {
		let cert = try Certificate(pemEncoded: pemEncoded)
		try self.init(certificate: cert, isSelfSigned: isSelfSigned)
	}
}

func check(certificateDomains: Set<String>, covers domains: [String]) -> Bool {
	var nonCovered = Set(domains).subtracting(certificateDomains)
	guard !nonCovered.isEmpty
	else { return true }

	for domain in nonCovered {
		var components = domain.split(separator: /\./)
		components[0] = "*"
		let joined = components.joined(separator: ".")
		if certificateDomains.contains(joined) {
			nonCovered.remove(domain)
		}
	}

	return nonCovered.isEmpty
}
