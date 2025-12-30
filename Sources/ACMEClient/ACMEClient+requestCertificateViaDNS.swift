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
		var nonce = nonce
		let (order, orderURL) = try await api.createOrder(
			NewOrderRequest(identifiers: domains.map { Identifier(type: .dns, value: $0.value) }),
			nonce: &nonce,
			accountKey: accountKey,
			accountURL: accountURL,
		)

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

	/// - Returns: True if any challenges required verification.
	private func verifyChallenges(order: Order, nonce: inout Nonce) async throws -> Bool {
		var nonDNS = [(URL, Authorization)]()
		var remainingAuths = [(URL, Challenge)]()

		let keyAuth = try KeyAuthorization(publicKey: accountKey.publicKey)

		for url in order.authorizations {
			let auth = try await api.authorization(at: url, nonce: &nonce, accountKey: accountKey, accountURL: accountURL)
			guard auth.status == .pending
			else {
				print("Auth for \(auth.identifier.value) is \(auth.status)")
				continue
			}

			guard let dnsChallenge = auth.challenges.first(where: { $0.type == .dns })
			else {
				nonDNS.append((url, auth))
				continue
			}

			remainingAuths.append((url, dnsChallenge))

			let domain = auth.identifier.value
			let txt = if domain.hasPrefix("*") {
				"_acme-challenge\(domain[domain.index(after: domain.startIndex)...])"
			} else {
				"_acme-challenge.\(domain)"
			}

			let digest = keyAuth.digest(for: dnsChallenge)
			print("""
			For \(domain), add a TXT record at \(txt) containing:
			- \(digest.base64urlEncodedString())
			""")
		}

		if !nonDNS.isEmpty {
			print("The following identifiers did not support DNS")

			for (_, auth) in nonDNS {
				print("--------")
				print("Auth for \(auth.identifier.value) cannot be automated")
				print("There are \(auth.challenges.count) challenges available")
				for idx in auth.challenges.indices {
					let challenge = auth.challenges[idx]
					print("\(idx): Challenge:\n\(challenge, indentedWith: "- ")")
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

					remainingAuths += try nonDNS.map { (url, auth) in
						let choice = chosenAuth.removeFirst()
						guard let challenge = auth.challenges[safe: choice]
						else {
							print("Choice for \(auth.identifier) was did not match option")
							throw CertificateChallengeError.invalidInputChoice
						}

						return (url, challenge)
					}

					break readKeyboard
				} catch {
					print("The input should be comma-separated numbers matching the number of non-DNS challenges, i.e. 1,4,2")
				}
			}
		}

		while !remainingAuths.isEmpty {
			for (_, challenge) in remainingAuths {
				try await api.respondTo(
					challenge,
					nonce: &nonce,
					accountKey: accountKey,
					accountURL: accountURL,
				)
			}

			try await Task.sleep(for: .seconds(30))

			for (url, _) in remainingAuths {
				let auth = try await api.authorization(at: url, nonce: &nonce, accountKey: accountKey, accountURL: accountURL)
				if auth.status != .pending {
					remainingAuths.removeAll { $0.0 == url }
				}

				logger.debug("Auth for \(auth.identifier) is still pending verifying, retrying")
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
