import ACMEClient
import ArgumentParser

struct AccountCommand: ParsableCommand {
	static let configuration = CommandConfiguration(
		commandName: "account",
		abstract: "Manage your account"
	)

	func run() throws {
		print("fetching account now")
		print(hello())
	}
}
