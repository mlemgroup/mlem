//
//  JSONDecoder+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-19.
//

import Foundation

extension JSONDecoder {
    internal static let backendDecoder: JSONDecoder = {
        let decoder: JSONDecoder = .init()
        decoder.dateDecodingStrategy = .custom { decoder in
            let formatter: ISO8601DateFormatter = .init()
            formatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime]
            let dateStr = try decoder.singleValueContainer().decode(String.self)
            if let date = formatter.date(from: dateStr) {
                return date
            }
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid date"))
        }
        return decoder
    }()
}
