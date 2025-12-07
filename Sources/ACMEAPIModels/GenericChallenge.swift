public import SwifterJSON

/// An ACME challenge object represents a server's offer to validate a
/// client's possession of an identifier in a specific way.  Unlike the
/// other objects listed above, there is not a single standard structure
/// for a challenge object.  The contents of a challenge object depend on
/// the validation method being used.  The general structure of challenge
/// objects and an initial set of validation methods are described in
/// [Section 8](https://datatracker.ietf.org/doc/html/rfc8555#section-8).
public struct GenericChallenge: Codable, Equatable, Sendable {
	public typealias Status = Challenge.Status

	/// Status of the challenge.
	///
	/// Challenge objects are created in the "pending" state.  They
	/// transition to the "processing" state when the client responds to the
	/// challenge (see Section 7.5.1) and the server begins attempting to
	/// validate that the client has completed the challenge.  Note that
	/// within the "processing" state, the server may attempt to validate the
	/// challenge multiple times (see Section 8.2).  Likewise, client
	/// requests for retries do not cause a state change.  If validation is
	/// successful, the challenge moves to the "valid" state; if there is an
	/// error, the challenge moves to the "invalid" state.
	///
	/// ### State Transitions for Challenge Objects
	/// ```
	///          pending
	///             |
	///             | Receive
	///             | response
	///             V
	///         processing <-+
	///             |   |    | Server retry or
	///             |   |    | client retry request
	///             |   +----+
	///             |
	///             |
	/// Successful  |   Failed
	/// validation  |   validation
	///   +---------+---------+
	///   |                   |
	///   V                   V
	/// valid              invalid
	/// ```
	public var status: Status

	public var allFields: [String: JSON]

	public init(status: Status, allFields: [String: JSON]) {
		self.status = status
		self.allFields = allFields
	}

	public init(from decoder: any Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.status = try container.decode(Status.self, forKey: .status)
		self.allFields = try [String: JSON](from: decoder)
	}

	public func encode(to encoder: any Encoder) throws {
		try allFields.encode(to: encoder)
	}

	enum CodingKeys: CodingKey {
		case status
	}
}

extension GenericChallenge: CustomStringConvertible {
	public var description: String {
		allFields
			.map { "\($0.key): \($0.value)" }
			.sorted()
			.joined(separator: "\n")
	}
}
