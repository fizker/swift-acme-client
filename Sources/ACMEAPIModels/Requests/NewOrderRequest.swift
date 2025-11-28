public import Foundation

public struct NewOrderRequest: Codable {
	public var identifiers: [Identifier]
	public var notBefore: Date
	public var notAfter: Date

	/// Creates a new request for creating an Order for a certificate.
	/// - parameters:
	///   - identifiers: The list of identifiers that the certificate should cover.
	///   - notBefore: The date from which the certificate should be valid. The default is now.
	///   - notAfter: The date that the certificate should expire on. The default value is 90 days from now.
	public init(
		identifiers: [Identifier],
		notBefore: Date = .now,
		// 90 days
		notAfter: Date = .init(timeIntervalSinceNow: 90 * 86_400),
	) {
		self.identifiers = identifiers
		self.notBefore = notBefore
		self.notAfter = notAfter
	}
}
