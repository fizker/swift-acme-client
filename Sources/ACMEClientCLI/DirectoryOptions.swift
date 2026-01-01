import ACMEAPIModels
import ArgumentParser

struct DirectoryOptions: ParsableArguments {
	@Option(
		name: .shortAndLong,
		help: """
		The URL for the directory of the ACME server. It can either be a HTTPS URL or a preset.
		""",
	)
	var directory: Directory
}
