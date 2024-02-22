//
//  JSONDecoder+Extensions.swift
//  Mlem
//
//  Created by Nicholas Lawson on 11/06/2023.
//

import Foundation

extension JSONDecoder {
    static var defaultDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss"
        ]
        
        let formatters = formats.map { format in
            let formatter = DateFormatter()
            formatter.timeZone = .gmt
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = format
            return formatter
        }

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            for formatter in formatters {
                if let date = formatter.date(from: string) {
                    return date
                }
            }

            // after some discussion we've agreed to fail the modelling if the date
            // does match _any_ of the above, as based on the current API source code
            // it should be one of those
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
