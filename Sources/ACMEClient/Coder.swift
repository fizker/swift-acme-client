import Foundation
import FzkExtensions

struct Coder {
	var decoder = JSONDecoder() ~ {
		$0.dateDecodingStrategy = .iso8601
	}
	var encoder = JSONEncoder() ~ {
		$0.dateEncodingStrategy = .iso8601
	}
}
let coder = Coder()
