public import Foundation

public struct NewOrderRequest: Codable {
	public var identifiers: [Identifier]
	public var notBefore: Date?
	public var notAfter: Date?

	/// Creates a new request for creating an Order for a certificate.
	/// - parameters:
	///   - identifiers: The list of identifiers that the certificate should cover.
	///   - notBefore: The date from which the certificate should be valid.
	///   - notAfter: The date that the certificate should expire on.
	public init(
		identifiers: [Identifier],
		notBefore: Date? = nil,
		// 90 days
		notAfter: Date? = nil,
	) {
		self.identifiers = identifiers
		self.notBefore = notBefore
		self.notAfter = notAfter
	}
}
