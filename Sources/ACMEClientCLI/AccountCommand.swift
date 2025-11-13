import ACMEClient
import ArgumentParser

struct AccountCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "account",
		abstract: "Manage your account"
	)

	@Option(name: .shortAndLong)
	var directory: Directory

	@Option(name: .shortAndLong, transform: { try .init(pemRepresentation: $0) })
	var accountKey: Key.Private

	func run() async throws {
		print("fetching account now: \(directory), \(directory.acme), \(directory.acme.rawValue)")
		let api = try await API(directory: directory.acme)
		var nonce = try await api.fetchNonce()
		let accountURL = try await api.fetchAccountURL(nonce: &nonce, accountKey: accountKey)
		print("Account: \(accountURL, default: "No URL returned")")
	}
}
