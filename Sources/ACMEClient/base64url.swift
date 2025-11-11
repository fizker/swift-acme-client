import Foundation
import FzkExtensions

extension Data {
	func base64urlEncodedString() -> String {
		return base64EncodedString()
			.trimmingSuffix { $0 == "=" }
			.replacing("+", with: "-")
			.replacing("/", with: "_")
			|> String.init
	}
}
