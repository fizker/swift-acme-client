import ACMEAPIModels
import Logging

struct AuthHandler {
	var type: Challenge.`Type`
	var logger = Logger(label: "AuthHandler")

	/// Handles authorizations via CLI.
	public func handleChallengesViaCLI(_ auths: [TypedAuthorization])
	throws(UnsupportedChallenges) -> [Verification]
	{
		var nonMatching = [TypedAuthorization]()
		var remainingAuths = [Verification]()

		for auth in auths {
			logger.trace("Fetched auth data for \(auth.identifier)")

			guard auth.status == .pending
			else {
				logger.debug("Auth for \(auth.identifier) is \(auth.status), skipping")
				continue
			}

			guard let verification = auth.verify(via: type)
			else {
				nonMatching.append(auth)
				continue
			}

			remainingAuths.append(verification)

			print(verification.challenge.directions)
		}

		guard nonMatching.isEmpty
		else {
			print("The following identifiers did not support \(type)")

			for auth in nonMatching {
				print("Auth for \(auth.identifier.value) cannot be automated")
			}
			throw UnsupportedChallenges()
		}

		if !remainingAuths.isEmpty {
			awaitKeyboardInput()
		}

		return remainingAuths
	}
}

public struct UnsupportedChallenges: Error {}

@discardableResult
func awaitKeyboardInput(message: String? = nil) -> String {
	if let message {
		print(message)
	}
	print("Press enter to continue")
	return readLine() ?? ""
}
