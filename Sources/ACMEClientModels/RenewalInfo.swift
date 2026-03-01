public import Foundation

public struct RenewalInfo {
	public var suggestedWindow: Window
	public var recommendedDateForNextCheck: Date
	public var explanationURL: URL?

	public init(
		suggestedWindow: Window,
		recommendedDateForNextCheck: Date,
		explanationURL: URL? = nil,
	) {
		self.suggestedWindow = suggestedWindow
		self.recommendedDateForNextCheck = recommendedDateForNextCheck
		self.explanationURL = explanationURL
	}

	public struct Window: Codable {
		public var start: Date
		public var end: Date

		public init(start: Date, end: Date) {
			self.start = start
			self.end = end
		}

		public var randomTime: Date {
			return Date(timeInterval: .random(in: 0..<end.timeIntervalSince(start)), since: start)
		}
	}
}
