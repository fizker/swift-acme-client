package import Foundation

package struct RenewalInfo: Codable {
	public var suggestedWindow: Window
	public var explanationURL: URL?

	public struct Window: Codable {
		public var start: Date
		public var end: Date

		public var randomTime: Date {
			return Date(timeInterval: .random(in: 0..<end.timeIntervalSince(start)), since: start)
		}
	}
}
