//
//  File.swift
//  Rest
//
//  Created by Sjmarf on 2025-11-14.
//  

import Foundation

// This simply throws an error as soon as you try to encode with it.
internal class SingleValueContainer: SingleValueEncodingContainer {
    let encoder: InternalURLQueryItemEncoder
    let codingPath: [CodingKey] = []

    init(encoder: InternalURLQueryItemEncoder) {
        self.encoder = encoder
    }

    func encodeNil() throws {}

    func encode(_ value: some Encodable) throws {
        throw URLQueryItemEncoderError.singleValueContainerUnsupported
    }
}
