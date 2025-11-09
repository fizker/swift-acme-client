import ArgumentParser

@main
struct CLI: ParsableCommand {
	static let configuration = CommandConfiguration(
		subcommands: [
			AccountCommand.self,
		],
	)
}
