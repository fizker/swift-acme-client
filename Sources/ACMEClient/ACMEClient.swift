public import ACMEClientModels
import FzkExtensions

let `1mb` = 1024 * 1024

public actor ACMEClient {
	let api: API

	public init(directory: ACMEDirectory) async throws {
		api = try await API(directory: directory)
	}
}
