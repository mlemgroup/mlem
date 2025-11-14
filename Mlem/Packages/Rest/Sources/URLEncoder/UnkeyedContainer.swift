//
//  File.swift
//  Rest
//
//  Created by Sjmarf on 2025-11-14.
//  

import Foundation

// This simply throws an error as soon as you try to encode with it.
internal class UnkeyedContainer: UnkeyedEncodingContainer {
    let encoder: any Encoder
    let codingPath: [any CodingKey] = []
    let count: Int = 0
    
    init(encoder: any Encoder) {
        self.encoder = encoder
    }
    
    func encodeNil() throws {}
    
    func encode(_ value: some Encodable) throws { throw URLQueryItemEncoderError.unkeyedContainerUnsupported }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        assertionFailure("We should throw an error *before* this gets called")
        return KeyedEncodingContainer(ThrowingKeyedContainer(encoder: encoder))
    }
    
    func nestedUnkeyedContainer() -> any UnkeyedEncodingContainer {
        assertionFailure("We should throw an error *before* this gets called")
        return UnkeyedContainer(encoder: encoder)
    }
    
    func superEncoder() -> any Encoder { encoder }
}
