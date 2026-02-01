public import Foundation
import FzkExtensions

public struct EmailURL: Equatable, Sendable {
	public let url: URL

	public init(_ url: URL) throws(ValidationError) {
		try self.init(url.absoluteString)
	}

	public init(_ value: String) throws(ValidationError) {
		let emailRegex = /(mailto:)?.+@.+\..+/
		let firstMatch = try? emailRegex.firstMatch(in: value)
		guard firstMatch != nil
		else { throw .contactMustBeEmail }

		var value = value
		if !value.hasPrefix("mailto:") {
			value = "mailto:\(value)"
		}

		url = try URL(string: value).unwrap(orThrow: ValidationError.contactMustBeEmail)
	}

	public enum ValidationError: Error {
		case contactMustBeEmail
	}
}

extension EmailURL: Codable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let url = try container.decode(URL.self)
		try self.init(url)
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(url)
	}
}
