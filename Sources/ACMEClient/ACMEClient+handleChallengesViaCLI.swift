extension ACMEClient {
	public func handleHTTPChallengesViaCLI(_ auths: [TypedAuthorization])
	throws(UnsupportedChallenges)
	-> [Verification]
	{
		let handler = AuthHandler(type: .http)
		return try handler.handleChallengesViaCLI(auths)
	}

	/// Handles authorizations via CLI.
	///
	/// This currently prefers DNS, and only presents other options if an auth does not have a DNS options.
	public func handleDNSChallengesViaCLI(_ auths: [TypedAuthorization])
	throws(UnsupportedChallenges)
	-> [Verification]
	{
		let handler = AuthHandler(type: .dns)
		return try handler.handleChallengesViaCLI(auths)
	}
}
