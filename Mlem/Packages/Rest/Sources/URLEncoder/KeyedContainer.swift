//
//  File.swift
//  Rest
//
//  Created by Sjmarf on 2025-11-14.
//  

import Foundation

internal class KeyedContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    var encoder: InternalURLQueryItemEncoder

    init(encoder: InternalURLQueryItemEncoder) {
        self.encoder = encoder
    }

    var codingPath: [CodingKey] = []

    func encodeNil(forKey key: K) throws {}

    func encode(_ value: some Encodable, forKey key: K) throws {
        if let valueString = convertValueToString(value) {
            let key = key.stringValue.camelToSnakeCase()
            encoder.queryParams.append(.init(name: key, value: valueString))
        } else {
            let encoder = RetrievalEncoder(userInfo: self.encoder.userInfo)
            try value.encode(to: encoder)
            if let wrappedValue = encoder.encodedValue, let valueString = convertValueToString(wrappedValue) {
                let key = key.stringValue.camelToSnakeCase()
                self.encoder.queryParams.append(.init(name: key, value: valueString))
            } else {
                throw URLQueryItemEncoderError.nestedContainersUnsupported
            }
        }
    }
    
    func convertValueToString(_ value: any Encodable) -> String? {
        if let value = value as? String {
            value
        } else if let value = value as? Int {
            String(value)
        } else if let value = value as? Double {
            String(value)
        } else if let value = value as? Bool {
            value ? "true" : "false"
        } else if let value = value as? URL {
            value.absoluteString
        } else if let value = value as? any URLQueryItemEncodable {
            value.encodeInQueryItemFormat()
        } else {
            nil
        }
    }

    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type, forKey key: K
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        assertionFailure("We should throw an error *before* this gets called")
        return KeyedEncodingContainer(KeyedContainer<NestedKey>(encoder: encoder))
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        assertionFailure("We should throw an error *before* this gets called")
        return UnkeyedContainer(encoder: encoder)
    }

    func superEncoder() -> Encoder { encoder }
    func superEncoder(forKey key: K) -> Encoder { encoder }
}
