
extension ACMEClient {
	/// Handles authorizations via CLI.
	///
	/// This currently prefers DNS, and only presents other options if an auth does not have a DNS options.
	public func handleDNSChallengesViaCLI(_ auths: [TypedAuthorization]) -> [Verification] {
		var nonDNS = [TypedAuthorization]()
		var remainingAuths = [Verification]()

		for auth in auths {
			logger.trace("Fetched auth data for \(auth.identifier)")

			guard auth.status == .pending
			else {
				logger.debug("Auth for \(auth.identifier) is \(auth.status), skipping")
				continue
			}

			guard let dnsChallenge = auth.verify(via: .dns)
			else {
				nonDNS.append(auth)
				continue
			}

			remainingAuths.append(dnsChallenge)

			guard case let .dns(x) = dnsChallenge.challenge
			else { fatalError() }

			print(x.directions)
		}

		if !nonDNS.isEmpty {
			print("The following identifiers did not support DNS")

			for auth in nonDNS {
				print("--------")
				print("Auth for \(auth.identifier.value) cannot be automated")
				print("There are \(auth.challenges.count) challenges available")
				for idx in auth.challenges.indices {
					let challenge = auth.challenges[idx]
					print("\(idx): \(challenge.directions)")
				}
			}
		}

		if nonDNS.isEmpty {
			guard !remainingAuths.isEmpty
			else { return [] }

			awaitKeyboardInput()
		} else {
			readKeyboard: while true {
				do {
					var chosenAuth = try awaitKeyboardInput(message: "Enter the chosen non-DNS solution as a comma-separated line")
					.split(separator: ",")
					.map { try Int("\($0)").unwrap() }

					guard chosenAuth.count == nonDNS.count
					else {
						throw CertificateChallengeError.invalidInputCount
					}

					remainingAuths += try nonDNS.map { auth in
						let choice = chosenAuth.removeFirst()
						guard let challenge = auth.verify(viaIndex: choice)
						else {
							print("Choice for \(auth.identifier) did not match option")
							throw CertificateChallengeError.invalidInputChoice
						}

						return challenge
					}

					break readKeyboard
				} catch {
					print("The input should be comma-separated numbers matching the number of non-DNS challenges, i.e. 1,4,2")
				}
			}
		}

		return remainingAuths
	}
}

@discardableResult
func awaitKeyboardInput(message: String? = nil) -> String {
	if let message {
		print(message)
	}
	print("Press enter to continue")
	return readLine() ?? ""
}
