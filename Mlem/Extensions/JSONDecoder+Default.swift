//
//  JSONDecoder+Default.swift
//  Mlem
//
//  Created by Nicholas Lawson on 11/06/2023.
//

import Foundation

extension JSONDecoder {
    static var defaultDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // swiftlint:disable opening_brace
        let pattern = /\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/
        let formatter = DateFormatter()
        formatter.timeZone = .gmt
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let alternate = /\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/
        let alternateFormatter = DateFormatter()
        alternateFormatter.timeZone = .gmt
        alternateFormatter.locale = Locale(identifier: "en_US_POSIX")
        alternateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        // swiftlint:enable opening_brace
        
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            var string = try container.decode(String.self)
            
            if let match = string.firstMatch(of: pattern),
               let date = formatter.date(from: String(match.output)) {
                return date
            }
            
            if let match = string.firstMatch(of: alternate),
               let date = alternateFormatter.date(from: String(match.output)) {
                return date
            }
            
            throw Swift.DecodingError.dataCorrupted(
                .init(
                    codingPath: container.codingPath,
                    debugDescription: "Failed to parse date"
                )
            )
        }
        
        return decoder
    }
}
