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

private let pollDelay: Duration = .seconds(10)
extension ACMEClient {
	/// A function that should handle authorizations by picking and meeting a challenge for each authorization.
	public typealias AuthorizationHandler = ([TypedAuthorization]) async throws -> [Verification]

	public func requestCertificate(
		covering domains: [Domain],
		authHandler: AuthorizationHandler,
	) async throws -> CertificateAndPrivateKey {
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

		let orderToFinalize = try await verifyChallenges(
			order: order,
			authHandler: authHandler,
			nonce: &nonce,
		)
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
				logger.debug("Sleeping \(pollDelay) before polling again")
				try await Task.sleep(for: pollDelay)
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
	private func verifyChallenges(
		order: Order,
		authHandler: AuthorizationHandler,
		nonce: inout Nonce,
	) async throws -> Bool {
		logger.trace("Verifying challenges")

		let keyAuth = try KeyAuthorization(publicKey: accountKey.publicKey)

		let auths = try await fetchAuthorizations(order: order, keyAuth: keyAuth, nonce: &nonce)

		let pendingAuths = auths.filter { $0.status == .pending }

		guard !pendingAuths.isEmpty
		else { return false }

		logger.trace("Informing user about challenges to verify")

		var remainingAuths: [Verification] = try await authHandler(pendingAuths)

		guard remainingAuths.map(\.auth.url.absoluteString).sorted() == pendingAuths.map(\.url.absoluteString).sorted()
		else { throw CertificateChallengeError.authorizationsUnhandled }

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

			try await Task.sleep(for: pollDelay)

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

public enum CertificateChallengeError: Error {
	case invalidInputCount
	case invalidInputChoice
	/// The verifications returned by the AuthorizationHandler does not match the authorizations given.
	case authorizationsUnhandled
	case orderFailed
}
