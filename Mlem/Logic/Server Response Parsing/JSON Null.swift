//
//  JSON Null.swift
//  Mlem
//
//  Created by David Bureš on 29.03.2022.
//

import Foundation

class JSONNull: Codable, Hashable
{
    public static func == (_: JSONNull, _: JSONNull) -> Bool
    {
        return true
    }

    public var hashValue: Int
    {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws
    {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil()
        {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
