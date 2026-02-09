
public struct UnsupportedChallenges: Error {}

extension ACMEClient {
	/// Handles authorizations via CLI.
	///
	/// This currently prefers DNS, and only presents other options if an auth does not have a DNS options.
	public func handleHTTPChallengesViaCLI(_ auths: [TypedAuthorization]) throws(UnsupportedChallenges) -> [Verification] {
		var nonDNS = [TypedAuthorization]()
		var remainingAuths = [Verification]()

		for auth in auths {
			logger.trace("Fetched auth data for \(auth.identifier)")

			guard auth.status == .pending
			else {
				logger.debug("Auth for \(auth.identifier) is \(auth.status), skipping")
				continue
			}

			guard let httpChallenge = auth.verify(via: .http)
			else {
				nonDNS.append(auth)
				continue
			}

			remainingAuths.append(httpChallenge)

			print(httpChallenge.challenge.directions)
		}

		guard nonDNS.isEmpty
		else {
			print("The following identifiers did not support HTTP")

			for auth in nonDNS {
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
