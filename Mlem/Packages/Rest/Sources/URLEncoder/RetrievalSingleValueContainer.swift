//
//  RetrievalSingleValueContainer.swift
//  Rest
//
//  Created by Sjmarf on 2025-11-14.
//  

import Foundation

internal class RetrievalSingleValueContainer: SingleValueEncodingContainer {
    let encoder: RetrievalEncoder
    let codingPath: [CodingKey] = []

    init(encoder: RetrievalEncoder) {
        self.encoder = encoder
    }

    func encodeNil() throws {}

    func encode(_ value: some Encodable) throws {
        encoder.encodedValue = value
    }
}
