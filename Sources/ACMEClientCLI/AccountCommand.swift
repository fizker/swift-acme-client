import ACMEAPIModels
import ACMEClient
import ACMEClientModels
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
	var options: DirectoryOptions

	@OptionGroup
	var auth: AccountKeyOptions

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
	var options: DirectoryOptions

	@OptionGroup
	var auth: AccountKeyOptions

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
		let account = try await api.createAccount(nonce: &nonce, accountKey: auth.accountKey, request: request)

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
	var options: DirectoryOptions

	@OptionGroup
	var auth: AuthOptions

	@OptionGroup
	var details: AccountDetailsOptions

	func run() async throws {
		let request = NewAccountRequest(contact: details.contact)
		let api = try await API(directory: options.directory.acme)
		var nonce = try await api.fetchNonce()

		let accountURL: URL
		if let a = auth.accountURL {
			accountURL = a
		} else {
			accountURL = try await api.fetchAccountURL(nonce: &nonce, accountKey: auth.accountKey)
		}

		let account = try await api.update(request, nonce: &nonce, accountKey: auth.accountKey, accountURL: accountURL)
		print("Updated account: \(account)")
	}
}

struct AccountDetailsOptions: ParsableArguments {
	@Option(
		name: .shortAndLong,
		parsing: .singleValue,
		help: """
		An e-mail address for the contact. This parameter can be repeated as needed.
		""",
		transform: EmailURL.init(_:),
	)
	var contact: [EmailURL]
}
