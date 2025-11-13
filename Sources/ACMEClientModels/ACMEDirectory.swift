import CompileSafeInitMacro
public import Foundation
import FzkExtensions

/// The URL for the `Directory` that contains all relevant URLs for a given ACME server.
public enum ACMEDirectory: Equatable, Hashable, Sendable {
	case letsEncryptV2Production
	case letsEncryptV2Staging
	case custom(URL)
}

extension ACMEDirectory: CaseIterable {
	/// Lists the supported directories.
	public static var allCases: [ACMEDirectory] {
		[ .letsEncryptV2Production, .letsEncryptV2Staging ]
	}
}

extension ACMEDirectory: Codable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let rawValue = try container.decode(URL.self)

		self = Self.init(rawValue: rawValue)
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(self.rawValue)
	}
}

extension ACMEDirectory: RawRepresentable {
	public init(rawValue: URL) {
		switch rawValue {
		case Self.letsEncryptV2Staging.rawValue:
			self = .letsEncryptV2Staging
		case Self.letsEncryptV2Production.rawValue:
			self = .letsEncryptV2Production
		default:
			self = .custom(rawValue)
		}
	}

	public var rawValue: URL {
		switch self {
		case .letsEncryptV2Production: return #URL("https://acme-v02.api.letsencrypt.org/directory")
		case .letsEncryptV2Staging: return #URL("https://acme-staging-v02.api.letsencrypt.org/directory")
		case let .custom(url): return url
		}
	}
}
