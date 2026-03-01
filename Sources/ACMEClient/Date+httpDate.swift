import Foundation

extension Date {
	/// Parses an HTTP-date as defined by RFC 9110 §5.6.7.
	/// Supports IMF-fixdate, obsolete RFC 850, and obsolete asctime formats, as well as the relative seconds since now.
	init?(httpDate string: String) {
		if let interval = TimeInterval(string) {
			self = Date(timeIntervalSinceNow: interval)
			return
		}

		// Common configuration
		let posix = Locale(identifier: "en_US_POSIX")
		let gmt = TimeZone(secondsFromGMT: 0)

		// 1) IMF-fixdate: Sun, 06 Nov 1994 08:49:37 GMT
		if let date = Date.httpDateFormatter(
			format: "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'",
			locale: posix,
			timeZone: gmt
		).date(from: string) {
			self = date
			return
		}

		// 2) Obsolete RFC 850: Sunday, 06-Nov-94 08:49:37 GMT
		if let date = Date.httpDateFormatter(
			format: "EEEE',' dd-MMM-yy HH':'mm':'ss 'GMT'",
			locale: posix,
			timeZone: gmt
		).date(from: string) {
			self = date
			return
		}

		// 3) Obsolete asctime: Sun Nov  6 08:49:37 1994
		if let date = Date.httpDateFormatter(
			format: "EEE MMM d HH':'mm':'ss yyyy",
			locale: posix,
			timeZone: gmt
		).date(from: string) {
			self = date
			return
		}

		// No match
		return nil
	}

	private static func httpDateFormatter(format: String, locale: Locale, timeZone: TimeZone?) -> DateFormatter {
		let df = DateFormatter()
		df.locale = locale
		df.timeZone = timeZone
		df.dateFormat = format
		return df
	}
}
