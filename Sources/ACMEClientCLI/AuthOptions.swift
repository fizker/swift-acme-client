import ACMEClient
import ArgumentParser
import Foundation

struct AccountKeyOptions: ParsableArguments {
	@Option(
		name: [.long, .customShort("k")],
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

struct AuthOptions: ParsableArguments {
	@OptionGroup
	private var ak: AccountKeyOptions

	var accountKey: Key.Private { ak.accountKey }

	@Option(
		name: [.customShort("u"), .long],
		help: """
		The URL for the account. If this is omitted, it will be requested from the ACME server.
		""",
		transform: { try URL(string: $0).unwrap() },
	)
	var accountURL: URL?
}
