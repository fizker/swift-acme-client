import ACMEAPIModels
public import ACMEClientModels
import Foundation
import JWTKit

/// The following table illustrates a typical sequence of requests required to prove control of
/// an identifier, issue a certificate, and fetch an updated certificate some time after issuance.
///
/// The "->" is a mnemonic for a Location header field pointing to a created resource.
///
/// ```
/// +-------------------+--------------------------------+--------------+
/// | Action            | Request                        | Response     |
/// +-------------------+--------------------------------+--------------+
/// | Submit order      | POST newOrder                  | 201 -> order |
/// |                   |                                |              |
/// | Fetch challenges  | POST-as-GET order's            | 200          |
/// |                   | authorization urls             |              |
/// |                   |                                |              |
/// | Respond to        | POST authorization challenge   | 200          |
/// | challenges        | urls                           |              |
/// |                   |                                |              |
/// | Poll for status   | POST-as-GET order              | 200          |
/// |                   |                                |              |
/// | Finalize order    | POST order's finalize url      | 200          |
/// |                   |                                |              |
/// | Poll for status   | POST-as-GET order              | 200          |
/// |                   |                                |              |
/// | Download          | POST-as-GET order's            | 200          |
/// | certificate       | certificate url                |              |
/// +-------------------+--------------------------------+--------------+
/// ```
extension ACMEClient {
	public func requestCertificateViaDNS(covering domains: [Domain]) async throws -> CertificateAndPrivateKey {
		logger.trace("Creating order")

		var nonce = nonce
		let (order, orderURL) = try await api.createOrder(
			NewOrderRequest(identifiers: domains.map { Identifier(type: .dns, value: $0.value) }),
			nonce: &nonce,
			accountKey: accountKey,
			accountURL: accountURL,
		)

		logger.trace("Order created", metadata: [
			"order": "\(order)",
		])

		guard order.status != .invalid
		else { throw CustomError(message: "Could not initiate order") }

		let orderToFinalize = try await verifyChallenges(order: order, nonce: &nonce)
			? try await pollForAuthCompleted(orderURL: orderURL)
			: order

		// ACMEAPIModels.ErrorType.orderNotReady error here would indicate that we might not be fully validated yet
		let (finalizedOrder, privateKey) = try await api.finalize(
			order: orderToFinalize,
			orderURL: orderURL,
			nonce: &nonce,
			accountKey: accountKey,
			accountURL: accountURL,
		)

		let certificateChain = try await api.downloadCertificateChain(
			for: finalizedOrder,
			nonce: &nonce,
			accountKey: accountKey,
			accountURL: accountURL,
		)

		return .init(certificateChain: certificateChain, privateKey: privateKey)
	}

	private func pollForAuthCompleted(orderURL: URL) async throws -> Order {
		repeat {
			let updatedOrder = try await api.order(
				url: orderURL,
				nonce: &nonce,
				accountKey: accountKey,
				accountURL: accountURL,
			)
			switch updatedOrder.status {
			case .pending:
				logger.debug("Sleeping 10s before polling again")
				try await Task.sleep(for: .seconds(10))
				break
			case .ready:
				// wat - this should only happen after we finalize
				fallthrough
			case .processing, .valid:
				return updatedOrder
			case .invalid:
				throw CertificateChallengeError.orderFailed
			}
		} while true
	}

	private func fetchAuthorizations(order: Order, keyAuth: KeyAuthorization, nonce: inout Nonce) async throws -> [TypedAuthorization] {
		logger.trace("Fetching authorizations")
		var auths: [TypedAuthorization] = []
		for url in order.authorizations {
			let auth = try await api.authorization(
				at: url,
				nonce: &nonce,
				accountKey: accountKey,
				accountURL: accountURL,
			)
			auths.append(try TypedAuthorization(auth, url: url, keyAuth: keyAuth))
		}
		logger.trace("Authorizations fetched")
		return auths
	}

	/// - Returns: True if any challenges required verification.
	private func verifyChallenges(order: Order, nonce: inout Nonce) async throws -> Bool {
		logger.trace("Verifying challenges")

		var nonDNS = [TypedAuthorization]()
		var remainingAuths = [Verification]()

		let keyAuth = try KeyAuthorization(publicKey: accountKey.publicKey)

		let auths = try await fetchAuthorizations(order: order, keyAuth: keyAuth, nonce: &nonce)

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
			else { return false }

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
							print("Choice for \(auth.identifier) was did not match option")
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

		logger.trace("User thinks challenges are ready for verification. Informing ACME server")

		while !remainingAuths.isEmpty {
			var postVerification: [Challenge] = []
			for verification in remainingAuths {
				let result = try await api.respondTo(
					verification.challenge,
					nonce: &nonce,
					accountKey: accountKey,
					accountURL: accountURL,
				)

				logger.debug("Received response to challenge with token \(verification.challenge.token): \(result)")

				if result.status == .pending {
					postVerification.append(result)
				}
			}

			guard !postVerification.isEmpty
			else { break }

			try await Task.sleep(for: .seconds(30))

			for verification in remainingAuths {
				let auth = try await api.authorization(at: verification.auth.url, nonce: &nonce, accountKey: accountKey, accountURL: accountURL)
				if auth.status != .pending {
					remainingAuths.removeAll { $0.auth.url == verification.auth.url }
				}

				logger.debug("Auth for \(auth.identifier) is still pending verification, retrying")
			}
		}

		return true
	}
}

enum CertificateChallengeError: Error {
	case invalidInputCount
	case invalidInputChoice
	case orderFailed
}
