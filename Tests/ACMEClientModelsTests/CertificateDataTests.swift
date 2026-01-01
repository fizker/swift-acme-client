import Crypto
import Foundation
import Testing
import X509
@testable import ACMEClientModels

struct CertificateDataTests {
	let testCert = try! generateCertificate(commonName: "test", domains: ["example.com"]).certificate

	@Test
	func initWithCertificate__certificateCoversSingleDomain__detectsTheEmbeddedDomains() async throws {
		let actual = try CertificateData(certificate: testCert, isSelfSigned: true)
		#expect(actual.domains == ["example.com"])
	}

	@Test
	func initWithCertificate__certificateCoversMultipleDomains__detectsTheEmbeddedDomains() async throws {
		let testCert = try generateCertificate(commonName: "test", domains: [
			"example.com",
			"foo.example.com",
			"bar.baz.example.com",
		]).certificate
		let actual = try CertificateData(certificate: testCert, isSelfSigned: true)
		#expect(actual.domains == [
			"example.com",
			"foo.example.com",
			"bar.baz.example.com",
		])
	}

	@Test(arguments: [
		(
			[
				"example.com",
				"foo.example.com",
			], [
				"example.com",
				"foo.example.com",
			]
		),
		(
			[
				"example.com",
				"foo.example.com",
			], [
				"example.com",
			]
		),
		(
			[
				"example.com",
				"foo.example.com",
			], [
				"foo.example.com",
			]
		),
	])
	func coversDomains__correctSubsets__returnsTrue(test: (lhs: [String], rhs: [String])) async throws {
		let (lhs, rhs) = test
		let data = CertificateData(domains: lhs, certificate: testCert, isSelfSigned: true)
		let isCovered = data.covers(domains: rhs)
		#expect(isCovered, "lhs: \(lhs), rhs: \(rhs)")
	}

	@Test(arguments: [
		(
			[
				"example.com",
			], [
				"example.com",
				"foo.example.com",
			]
		),
		(
			[
				"foo.example.com",
			], [
				"example.com",
				"foo.example.com",
			]
		),
	])
	func coversDomains__incorrectSubsets__returnsFalse(test: (lhs: [String], rhs: [String])) async throws {
		let (lhs, rhs) = test
		let data = CertificateData(domains: lhs, certificate: testCert, isSelfSigned: true)
		let actual = data.covers(domains: rhs)
		#expect(actual == false)
	}

	@Test(arguments: [
		(
			[
				"*.example.com",
			], [
				"foo.example.com",
				"bar.example.com",
			],
			true
		),
		(
			[
				"example.com",
				"*.example.com",
			], [
				"example.com",
				"foo.example.com",
				"bar.example.com",
			],
			true
		),
		(
			[
				"*.example.com",
			], [
				"example.com",
				"foo.example.com",
			],
			false
		),
		(
			[
				"*.example.com",
			], [
				"foo.example.com",
				"bar.baz.example.com",
			],
			false
		),
	])
	func coversDomains__includesWildcards__matchesCorrectly(lhs: [String], rhs: [String], expected: Bool) async throws {
		let data = CertificateData(domains: lhs, certificate: testCert, isSelfSigned: true)
		let actual = data.covers(domains: rhs)
		#expect(actual == expected)
	}
}

func generateCertificate(commonName: String, domains: [String]) throws -> CertificateData {
	let key = P256.Signing.PrivateKey()

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

	return CertificateData(domains: domains, certificate: cert, isSelfSigned: true)
}
