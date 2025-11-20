import ACMEAPIModels
import ACMEClient
import ArgumentParser
import Foundation
import FzkExtensions

struct AccountCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "account",
		abstract: "Manage your account.",
		subcommands: [
			CreateAccountKeyCommand.self,
			CreateAccountCommand.self,
			UpdateAccountCommand.self,
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

	@Option(help: "The file path that the new key should be written to.")
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
		abstract: """
		Fetches account details from the ACME server.
		""",
	)

	@OptionGroup
	var options: AccountOptions

	@OptionGroup
	var auth: AuthOptions

	func run() async throws {
		print("fetching account now: \(options.directory), \(options.directory.acme), \(options.directory.acme.rawValue)")
		let api = try await API(directory: options.directory.acme)
		var nonce = try await api.fetchNonce()
		let accountURL = try await api.fetchAccountURL(nonce: &nonce, accountKey: auth.accountKey)
		print("AccountURL: \(accountURL)")
		let account = try await api.fetchAccount(nonce: &nonce, accountKey: auth.accountKey, accountURL: accountURL)
		print("Account: \(account, default: "No Account returned")")
	}
}

struct CreateAccountCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "create",
		abstract: """
		Creates a new account.
		""",
	)

	@OptionGroup
	var options: AccountOptions

	@OptionGroup
	var auth: AuthOptions

	@OptionGroup
	var details: AccountDetailsOptions

	func run() async throws {
		let request = NewAccountRequest(
			contact: details.contact,
			termsOfServiceAgreed: true,
			externalAccountBinding: nil,
		)
		let api = try await API(directory: options.directory.acme)
		var nonce = try await api.fetchNonce()
		guard let account = try await api.createAccount(nonce: &nonce, accountKey: auth.accountKey, request: request)
		else {
			print("Failed to create account")
			return
		}

		print("Account: \(account.account)")
		print("URL: \(account.url)")
	}
}

struct UpdateAccountCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "update",
		abstract: """
		Updates an existing account.
		""",
	)

	@OptionGroup
	var options: AccountOptions

	@OptionGroup
	var auth: AuthOptions

	@OptionGroup
	var details: AccountDetailsOptions

	@Option(
		name: [.customShort("u"), .long],
		help: """
		The URL for the account. If this is omitted, it will be requested from the ACME server.
		""",
		transform: { try URL(string: $0).unwrap() },
	)
	var accountURL: URL?

	func run() async throws {
		let request = NewAccountRequest(contact: details.contact)
		let api = try await API(directory: options.directory.acme)
		var nonce = try await api.fetchNonce()

		let accountURL: URL
		if let a = self.accountURL {
			accountURL = a
		} else {
			accountURL = try await api.fetchAccountURL(nonce: &nonce, accountKey: auth.accountKey)
		}

		let account = try await api.update(request, nonce: &nonce, accountKey: auth.accountKey, accountURL: accountURL)
		print("Updated account: \(account)")
	}
}

func parseEmailURL(value: String) throws -> URL {
	let emailRegex = /(mailto:)?.+@.+\..+/
	guard try emailRegex.firstMatch(in: value) != nil
	else {
		throw ValidationError("Expected a mailto: URL")
	}
	var value = value
	if !value.hasPrefix("mailto:") {
		value = "mailto:\(value)"
	}
	return try URL(string: value).unwrap()
}

struct AccountOptions: ParsableArguments {
	@Option(
		name: .shortAndLong,
		help: """
		The URL for the directory of the ACME server. It can either be a HTTPS URL or a preset.
		""",
	)
	var directory: Directory
}

struct AuthOptions: ParsableArguments {
	@Option(
		name: .shortAndLong,
		help: """
		The path to a file containing a PEM representation of the private key for the Account.
		""",
		transform: {
			let data = try FileManager.default.contents(atPath: $0).unwrap()
			let content = try String(data: data, encoding: .utf8).unwrap()
			return try .init(pemRepresentation: content)
		},
	)
	var accountKey: Key.Private
}

struct AccountDetailsOptions: ParsableArguments {
	@Option(
		name: .shortAndLong,
		parsing: .singleValue,
		help: """
		An e-mail address for the contact. This parameter can be repeated as needed.
		""",
		transform: parseEmailURL(value:),
	)
	var contact: [URL]
}
