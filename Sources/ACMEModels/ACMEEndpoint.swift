public import Foundation
import FzkExtensions

public enum ACMEEndpoint: Equatable, Hashable, Sendable {
	case letsEncryptV2Production
	case letsEncryptV2Staging
}

extension ACMEEndpoint: Codable {
	public init(from decoder: any Decoder) throws {
		enum CodingKeys: String, CodingKey {
			case relative
		}

		let rawValue: URL

		do {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			rawValue = try container.decode(URL.self, forKey: .relative)
		} catch {
			let container = try decoder.singleValueContainer()
			rawValue = try container.decode(URL.self)
		}

		self = try Self.init(rawValue: rawValue).unwrap(orThrow: DecodingError.dataCorrupted(
			.init(
				codingPath: [],
				debugDescription: "Unsupported URL: \(rawValue)"
			))
		)
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(self.rawValue)
	}
}

extension ACMEEndpoint: RawRepresentable {
	public init?(rawValue: URL) {
		switch rawValue {
		case Self.letsEncryptV2Staging.rawValue:
			self = .letsEncryptV2Staging
		case Self.letsEncryptV2Production.rawValue:
			self = .letsEncryptV2Production
		default: return nil
		}
	}

	public var rawValue: URL {
		switch self {
		case .letsEncryptV2Production: return URL(string: "https://acme-v02.api.letsencrypt.org/directory")!
		case .letsEncryptV2Staging: return URL(string: "https://acme-staging-v02.api.letsencrypt.org/directory")!
		}
	}
}
