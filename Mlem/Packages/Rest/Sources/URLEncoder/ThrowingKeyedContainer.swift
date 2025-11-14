//
//  File.swift
//  Rest
//
//  Created by Sjmarf on 2025-11-14.
//  

import Foundation

internal class ThrowingKeyedContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    var encoder: any Encoder

    init(encoder: any Encoder) {
        self.encoder = encoder
    }

    var codingPath: [CodingKey] = []

    func encodeNil(forKey key: K) throws {}

    func encode(_ value: some Encodable, forKey key: K) throws {
        throw URLQueryItemEncoderError.nestedContainersUnsupported
    }

    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type, forKey key: K
    ) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        assertionFailure("We should throw an error *before* this gets called")
        return KeyedEncodingContainer(ThrowingKeyedContainer<NestedKey>(encoder: encoder))
    }

    func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        assertionFailure("We should throw an error *before* this gets called")
        return UnkeyedContainer(encoder: encoder)
    }

    func superEncoder() -> Encoder { encoder }
    func superEncoder(forKey key: K) -> Encoder { encoder }
}
