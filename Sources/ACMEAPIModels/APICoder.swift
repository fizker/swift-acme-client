public import Foundation
import FzkExtensions
public import NIOCore
import NIOFoundationCompat

public struct APICoder: Sendable {
	let encoder: JSONEncoder
	let decoder: JSONDecoder

	public init(
		encoder: JSONEncoder = .acmeAPIModelsPreconfigured,
		decoder: JSONDecoder = .acmeAPIModelsPreconfigured,
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

	public func decode<T: Decodable>(_ buffer: ByteBuffer) throws -> T {
		try decoder.decode(T.self, from: buffer)
	}
}

/// Preconfigured compatible Encoder/Decoder pair.
public let apiCoder = APICoder()

extension JSONDecoder {
	/// Preconfigured JSONDecoder with settings matching ``JSONEncoder/acmeAPIModelsPreconfigured``
	public static var acmeAPIModelsPreconfigured: JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
		decoder.allowsJSON5 = true
		return decoder
	}
}

extension JSONEncoder {
	/// Preconfigured JSONDecoder with settings matching ``JSONDecoder/acmeAPIModelsPreconfigured``
	public static var acmeAPIModelsPreconfigured: JSONEncoder {
		let encoder = JSONEncoder()
		encoder.outputFormatting = [ .prettyPrinted, .sortedKeys ]
		encoder.dateEncodingStrategy = .iso8601
		return encoder
	}
}
