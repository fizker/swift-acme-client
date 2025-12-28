import Crypto
import Foundation
import FzkExtensions

extension Digest {
	func base64urlEncodedString() -> String {
		return Data(self).base64urlEncodedString()
	}
}

extension Data {
	func base64urlEncodedString() -> String {
		return base64EncodedString()
			.trimmingSuffix { $0 == "=" }
			.replacing("+", with: "-")
			.replacing("/", with: "_")
			|> String.init
	}
}
