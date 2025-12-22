public import X509

extension Certificate: @retroactive Codable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let pem = try container.decode(String.self)
		try self.init(pemEncoded: pem)
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		let pem = try serializeAsPEM()
		try container.encode(pem.pemString)
	}
}

extension Certificate.PrivateKey: @retroactive Codable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let pem = try container.decode(String.self)
		try self.init(pemEncoded: pem)
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		let pem = try serializeAsPEM()
		try container.encode(pem.pemString)
	}
}
