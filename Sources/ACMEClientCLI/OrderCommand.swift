import ACMEClient
import ArgumentParser
import Foundation

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

	@Option(name: .shortAndLong, transform: { URL(fileURLWithPath: $0) })
	var output: URL

	func run() async throws {
		let client = try await ACMEClient(
			directory: options.directory.acme,
			accountKey: auth.accountKey,
			accountURL: auth.accountURL,
		)

		let certificate = try await client.requestCertificateViaDNS(covering: [
			Domain("fizkerinc.dk")!,
			Domain("test.fizkerinc.dk")!,
			Domain("foo.fizkerinc.dk")!,
		])

		let encoder = JSONEncoder()
		let data = try encoder.encode(certificate)
		try data.write(to: output)
	}
}
