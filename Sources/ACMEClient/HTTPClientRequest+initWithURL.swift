import AsyncHTTPClient
import Foundation

extension HTTPClientRequest {
	init(url: URL) {
		self.init(url: url.absoluteString)
	}
}
