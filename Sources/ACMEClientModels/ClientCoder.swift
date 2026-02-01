public import Foundation
import FzkExtensions

/// A coder wrapper that will be used when encoding and decoding messages for the ACME client.
///
/// A pre-configured version of this is exposed as ``clientCoder``, or a new instance can be created
/// with the same setup by calling the primary ``init(encoder:decoder:)`` with no parameters.
public struct ClientCoder: Sendable {
	let encoder: JSONEncoder
	let decoder: JSONDecoder

	/// Creates a new `ClientCoder`. The default value for the init matches the preconfigured ``clientCoder``
	/// instance.
	public init(
		encoder: JSONEncoder = .acmeClientModelsPreconfigured,
		decoder: JSONDecoder = .acmeClientModelsPreconfigured,
	) {
		self.encoder = encoder
		self.decoder = decoder
	}

	/// Encodes the given value according to the configured `JSONEncoder`.
	public func encode(_ value: some Encodable) throws -> Data {
		try encoder.encode(value)
	}

	/// Decodes the given data using the configured `JSONDecoder`.
	///
	/// Example:
	///
	/// ```swift
	/// let certChain = try clientCoder.decode(incomingData) as CertificateChain
	/// ```
	public func decode<T: Decodable>(_ data: Data) throws -> T {
		try decoder.decode(T.self, from: data)
	}
}

/// Preconfigured compatible Encoder/Decoder pair.
public let clientCoder = ClientCoder()

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
