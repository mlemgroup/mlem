//
//  File.swift
//  Rest
//
//  Created by Sjmarf on 2025-11-14.
//  

import Foundation

internal class InternalURLQueryItemEncoder: Encoder {
    var queryParams: [URLQueryItem] = .init()

    // This is just for conformance to Encoder. This never gets modified because we
    // disallow nested containers
    let codingPath: [CodingKey] = []
    
    let userInfo: [CodingUserInfoKey: Any] 

    init(userInfo: [CodingUserInfoKey: Any]) {
        self.userInfo = userInfo
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        // This value throws an error as soon as you try to encode with it
        ThrowingSingleValueContainer(encoder: self)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        // This value throws an error as soon as you try to encode with it
        ThrowingUnkeyedContainer(encoder: self)
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        KeyedEncodingContainer(TopLevelKeyedContainer<Key>(encoder: self))
    }
}
