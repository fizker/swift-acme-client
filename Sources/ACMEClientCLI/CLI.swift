import ArgumentParser

@main
struct CLI: AsyncParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "acme-client",
		subcommands: [
			AccountCommand.self,
			OrderCommand.self,
		],
	)
}
