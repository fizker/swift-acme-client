public struct ACMEProblem: Codable, Error, Equatable, Sendable {
	public var type: ErrorType
	public var detail: String
	public var status: Int?
	public var instance: String?
	public var subproblems: [ACMESubproblem]?

	public init(type: ErrorType, detail: String, status: Int? = nil, instance: String? = nil, subproblems: [ACMESubproblem]? = nil) {
		self.type = type
		self.detail = detail
		self.status = status
		self.instance = instance
		self.subproblems = subproblems
	}
}

public struct ACMESubproblem: Codable, Error, Equatable, Sendable {
	public var type: ErrorType
	public var detail: String
	public var instance: String?
	public var identifier: Identifier?

	public init(type: ErrorType, detail: String, instance: String? = nil, identifier: Identifier? = nil) {
		self.type = type
		self.detail = detail
		self.instance = instance
		self.identifier = identifier
	}
}
