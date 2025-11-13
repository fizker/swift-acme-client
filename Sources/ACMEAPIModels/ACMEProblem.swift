public struct ACMEProblem: Codable, Error, Equatable, Sendable {
	public var type: ErrorType
	public var detail: String
	public var status: Int?
	public var instance: String?
	public var subproblems: [ACMESubproblem]?
}

public struct ACMESubproblem: Codable, Error, Equatable, Sendable {
	public var type: ErrorType
	public var detail: String
	public var instance: String?
	public var identifier: Identifier?
}
