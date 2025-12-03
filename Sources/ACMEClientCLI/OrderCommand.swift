import ACMEClient
import ArgumentParser

struct OrderCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "order",
		abstract: "Manage orders",
		subcommands: [
			CreateOrderCommand.self,
		],
	)
}

struct CreateOrderCommand: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "create",
	)

	@OptionGroup
	var options: DirectoryOptions

	@OptionGroup
	var auth: AuthOptions

	func run() async throws {
		let client = try await ACMEClient(
			directory: options.directory.acme,
			accountKey: auth.accountKey,
			accountURL: auth.accountURL,
		)

		try await client.requestCertificateViaDNS(covering: [
			Domain("fizkerinc.dk")!,
			Domain("test.fizkerinc.dk")!,
			Domain("foo.fizkerinc.dk")!,
		])
	}
}
