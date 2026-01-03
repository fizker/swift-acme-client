public import Crypto

public enum Key {
	public typealias Private = P256.Signing.PrivateKey
	public typealias Public = P256.Signing.PublicKey
}

extension P256.Signing.PrivateKey: @retroactive Codable {
	public init(from decoder: any Decoder) throws {
		let container = try decoder.singleValueContainer()
		let pem = try container.decode(String.self)
		try self.init(pemRepresentation: pem)
	}

	public func encode(to encoder: any Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(pemRepresentation)
	}
}
