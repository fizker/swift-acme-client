public import ACMEAPIModels

extension ACMEClient {
	/// Handles authorizations via CLI.
	///
	/// - parameter type: The type of challenge to attempt.
	/// - throws: Unless every challenge supports HTTP, this will throw `UnsupportedChallenges`.
	public func challengeHandler(for type: Challenge.`Type`) -> ([TypedAuthorization])
	throws(UnsupportedChallenges)
	-> [Verification]
	{
		let handler = AuthHandler(type: type)
		return handler.handleChallengesViaCLI
	}

	/// Handles authorizations via CLI.
	///
	/// - parameter auths: The authorizations to handle.
	/// - returns: A list of verifications to transmit to the server.
	/// - throws: Unless every challenge supports HTTP, this will throw `UnsupportedChallenges`.
	public func handleHTTPChallengesViaCLI(_ auths: [TypedAuthorization])
	throws(UnsupportedChallenges)
	-> [Verification]
	{
		let handler = AuthHandler(type: .http)
		return try handler.handleChallengesViaCLI(auths)
	}

	/// Handles authorizations via CLI.
	///
	/// - parameter auths: The authorizations to handle.
	/// - returns: A list of verifications to transmit to the server.
	/// - throws: Unless every challenge supports DNS, this will throw `UnsupportedChallenges`.
	public func handleDNSChallengesViaCLI(_ auths: [TypedAuthorization])
	throws(UnsupportedChallenges)
	-> [Verification]
	{
		let handler = AuthHandler(type: .dns)
		return try handler.handleChallengesViaCLI(auths)
	}
}
