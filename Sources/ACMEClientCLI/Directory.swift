import ACMEClientModels
import ArgumentParser
import Foundation

enum Directory {
	case letsEncryptProduction, letsEncryptStaging
	case custom(URL)

	var acme: ACMEDirectory {
		switch self {
		case .letsEncryptProduction: .letsEncryptV2Production
		case .letsEncryptStaging: .letsEncryptV2Staging
		case let .custom(url): .custom(url)
		}
	}
}
extension Directory: CaseIterable {
	static var allCases: [Directory] { [.letsEncryptProduction, .letsEncryptStaging] }
}
extension Directory: ExpressibleByArgument {
	enum Error: Swift.Error {
		case supportedShortHands([String])
	}
	init?(argument: String) {
		switch argument {
		case "lets-encrypt-production": self = .letsEncryptProduction
		case "lets-encrypt-staging": self = .letsEncryptStaging
		default:
			guard argument.starts(with: "http")
			else {
				return nil
			}

			guard let url = URL(string: argument)
			else { return nil }
			self = .custom(url)
		}
	}

	static var allValueStrings: [String] { [
		"lets-encrypt-production",
		"lets-encrypt-staging",
	] }
}
