//
//  RetrievalEncoder.swift
//  Rest
//
//  Created by Sjmarf on 2025-11-14.
//  

import Foundation

internal class RetrievalEncoder: Encoder {
    // This is just for conformance to Encoder. This never gets modified because we
    // disallow nested containers
    let codingPath: [CodingKey] = []
    
    // Just for conformance; unused
    let userInfo: [CodingUserInfoKey: Any] = [:]

    func singleValueContainer() -> SingleValueEncodingContainer {
        // This value throws an error as soon as you try to encode with it
        RetrievalSingleValueContainer(encoder: self)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        // This value throws an error as soon as you try to encode with it
        UnkeyedContainer(encoder: self)
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        KeyedEncodingContainer(ThrowingKeyedContainer<Key>(encoder: self))
    }
}
