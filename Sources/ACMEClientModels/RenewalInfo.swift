public import Foundation

public struct RenewalInfo: Codable {
	public var suggestedWindow: Window
	public var recommendedDateForNextCheck: Date
	public var explanationURL: URL?
	package var certificateIdentifier: String?

	public init(
		suggestedWindow: Window,
		recommendedDateForNextCheck: Date,
		explanationURL: URL? = nil,
	) {
		self.suggestedWindow = suggestedWindow
		self.recommendedDateForNextCheck = recommendedDateForNextCheck
		self.explanationURL = explanationURL
	}

	enum CodingKeys: String, CodingKey {
		case suggestedWindow
		case recommendedDateForNextCheck
		case explanationURL
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
