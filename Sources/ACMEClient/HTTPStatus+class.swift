import NIOHTTP1

extension HTTPResponseStatus {
	/// The different classes that a HTTPStatus can have.
	///
	/// They are defined and named by [RFC7231](https://datatracker.ietf.org/doc/html/rfc7231#section-6).
	enum StatusClass {
		/// 1xx (Informational): The request was received, continuing process
		case informational
		/// 2xx (Successful): The request was successfully received, understood, and accepted
		case successful
		/// 3xx (Redirection): Further action needs to be taken in order to complete the request
		case redirection
		/// 4xx (Client Error): The request contains bad syntax or cannot be fulfilled
		case clientError
		/// 5xx (Server Error): The server failed to fulfill an apparently valid request
		case serverError
		/// <100 and >= 600: Not part of the HTTP standard, but technically possible to set.
		case unknown
	}

	/// The class that this HTTPStatus has.
	///
	/// They are defined and named by [RFC7231](https://datatracker.ietf.org/doc/html/rfc7231#section-6).
	var `class`: StatusClass {
		switch code {
		case 100..<200:
			return .informational
		case 200..<300:
			return .successful
		case 300..<400:
			return .redirection
		case 400..<500:
			return .clientError
		case 500..<600:
			return .serverError
		default:
			return .unknown
		}
	}

	var isSuccess: Bool {
		`class` == .successful
	}

	var isServerError: Bool {
		`class` == .serverError
	}

	var isClientError: Bool {
		`class` == .clientError
	}

	var isError: Bool {
		code >= 400
	}
}
