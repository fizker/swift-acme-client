public import Foundation
import FzkExtensions

public struct Coder: Sendable {
	let encoder: JSONEncoder
	let decoder: JSONDecoder

	public init(
		encoder: JSONEncoder = .acmeClientModelsPreconfigured,
		decoder: JSONDecoder = .acmeClientModelsPreconfigured,
	) {
		self.encoder = encoder
		self.decoder = decoder
	}

	public func encode(_ value: some Encodable) throws -> Data {
		try encoder.encode(value)
	}

	public func decode<T: Decodable>(_ data: Data) throws -> T {
		try decoder.decode(T.self, from: data)
	}
}

/// Preconfigured compatible Encoder/Decoder pair.
public let coder = Coder()

extension JSONDecoder {
	/// Preconfigured JSONDecoder with settings matching ``JSONEncoder/acmeClientModelsPreconfigured``
	public static var acmeClientModelsPreconfigured: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
		decoder.dataDecodingStrategy = .base64
		decoder.allowsJSON5 = true
		return decoder
	}
}

extension JSONEncoder {
	/// Preconfigured JSONDecoder with settings matching ``JSONDecoder/acmeClientModelsPreconfigured``
	public static var acmeClientModelsPreconfigured: JSONEncoder {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [ .prettyPrinted, .sortedKeys ]
		encoder.dateEncodingStrategy = .iso8601
		encoder.dataEncodingStrategy = .base64
		return encoder
	}
}
