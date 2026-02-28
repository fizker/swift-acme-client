import ACMEAPIModels
import ACMEClient
import ACMEClientModels
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

	@Option(
		name: .shortAndLong,
		help: """
		The validation method to use.
		""",
	)
	var method: ValidationMethod

	@OptionGroup
	var options: DirectoryOptions

	@OptionGroup
	var auth: AuthOptions

	@Option(name: .shortAndLong, transform: { URL(fileURLWithPath: $0) })
	var output: URL

	@Argument(transform: { try Domain($0).unwrap() })
	var domains: [Domain]

	func run() async throws {
		let client = try await ACMEClient(
			directory: options.directory.acme,
			accountKey: auth.accountKey,
			accountURL: auth.accountURL,
		)

		let certificate = try await client.requestCertificate(
			covering: domains,
			authHandler: client.challengeHandler(for: method.challengeType),
		)

		let data = try clientCoder.encode(certificate)
		try data.write(to: output)
	}

	enum ValidationMethod: String, CaseIterable, ExpressibleByArgument {
		case dns, http

		var challengeType: Challenge.`Type` {
			switch self {
			case .dns: .dns
			case .http: .http
			}
		}
	}
}
