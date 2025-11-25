public import Foundation

public struct NewOrderRequest: Codable {
	public var identifiers: [Identifier]
	public var notBefore: Date
	public var notAfter: Date

	public init(identifiers: [Identifier], notBefore: Date, notAfter: Date) {
		self.identifiers = identifiers
		self.notBefore = notBefore
		self.notAfter = notAfter
	}
}
