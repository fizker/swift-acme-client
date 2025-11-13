import ACMEClient
import ArgumentParser
import Foundation
import FzkExtensions

struct AccountCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "account",
		abstract: "Manage your account"
	)

	@Option(name: .shortAndLong)
	var directory: Directory

	@Option(name: .shortAndLong, transform: {
		print("path: \($0)")
		let data = try FileManager.default.contents(atPath: $0).unwrap()
		let content = try String(data: data, encoding: .utf8).unwrap()
		print("content: \(content)")
		return try .init(pemRepresentation: content)
	})
	var accountKey: Key.Private

	func run() async throws {
		print("fetching account now: \(directory), \(directory.acme), \(directory.acme.rawValue)")
		let api = try await API(directory: directory.acme)
		var nonce = try await api.fetchNonce()
		let accountURL = try await api.fetchAccountURL(nonce: &nonce, accountKey: accountKey)
			.unwrap()
		print("AccountURL: \(accountURL, default: "No URL returned")")
		let account = try await api.fetchAccount(nonce: &nonce, accountKey: accountKey, accountURL: accountURL)
		print("Account: \(account, default: "No Account returned")")
	}
}
