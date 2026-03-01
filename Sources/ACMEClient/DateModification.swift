import Foundation

extension Date {
	func adding(_ value: Modification, _ more: Modification...) -> Date {
		let ti = more.map(\.asTimeInterval).reduce(value.asTimeInterval, +)
		return addingTimeInterval(ti)
	}

	enum Modification {
		case days(Int)
		case seconds(Int)
		case minutes(Int)
		case hours(Int)

		var asTimeInterval: TimeInterval {
			switch self {
			case let .days(value): TimeInterval(24 * 3600 * value)
			case let .seconds(value): TimeInterval(value)
			case let .minutes(value): TimeInterval(60 * value)
			case let .hours(value): TimeInterval(3600 * value)
			}
		}
	}
}
