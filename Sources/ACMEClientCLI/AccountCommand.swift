import ACMEAPIModels
import ACMEClient
import ArgumentParser
import Foundation
import FzkExtensions

struct AccountOptions: ParsableArguments {
	@Option(name: .shortAndLong)
	var directory: Directory
}

struct AccountCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "account",
		abstract: "Manage your account",
		subcommands: [
			CreateAccountKeyCommand.self,
			FetchAccountCommand.self,
		],
	)
}

struct CreateAccountKeyCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "key",
		abstract: """
		Generates a new private key for use with accounts.
		""",
	)

	@Option
	var output: String

	func run() async throws {
		let key = Key.Private()
		let fm = FileManager.default
		fm.createFile(atPath: output, contents: Data(key.pemRepresentation.utf8))
	}
}

struct FetchAccountCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "fetch",
	)

	@OptionGroup
	var options: AccountOptions

	@Option(name: .shortAndLong, transform: {
		let data = try FileManager.default.contents(atPath: $0).unwrap()
		let content = try String(data: data, encoding: .utf8).unwrap()
		return try .init(pemRepresentation: content)
	})
	var accountKey: Key.Private

	func run() async throws {
		print("fetching account now: \(options.directory), \(options.directory.acme), \(options.directory.acme.rawValue)")
		let api = try await API(directory: options.directory.acme)
		var nonce = try await api.fetchNonce()
		let accountURL = try await api.fetchAccountURL(nonce: &nonce, accountKey: accountKey)
			.unwrap()
		print("AccountURL: \(accountURL, default: "No URL returned")")
		let account = try await api.fetchAccount(nonce: &nonce, accountKey: accountKey, accountURL: accountURL)
		print("Account: \(account, default: "No Account returned")")
	}
}

struct CreateAccountCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "create",
	)

	@OptionGroup
	var options: AccountOptions

	@Option(name: .shortAndLong, parsing: .singleValue, transform: parseEmailURL(value:))
	var contact: [URL]

	func run() async throws {
		let request = NewAccountRequest(contact: contact, termsOfServiceAgreed: true, externalAccountBinding: nil)
	}
}

func parseEmailURL(value: String) throws -> URL {
	let emailRegex = /mailto:.+/
	guard try emailRegex.firstMatch(in: value) != nil
	else {
		throw ValidationError("Expected a mailto: URL")
	}
	return try URL(string: value).unwrap()
}
