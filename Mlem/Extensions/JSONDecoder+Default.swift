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

        let formatter = DateFormatter()

        formatter.timeZone = .gmt
        formatter.locale = Locale(identifier: "en_US_POSIX")

        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
            "yyyy-MM-dd'T'HH:mm:ss.SSSSZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSS",
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd HH:mm:ss.SSSSSS",
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd"
        ]

        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: string) {
                    return date
                }
            }

            // after some discussion we've agreed to fail the modelling if the date
            // does match either of the above, as based on the current API source code
            // it should be one of those
            throw Swift.DecodingError.dataCorrupted(
                .init(codingPath: container.codingPath,
                      debugDescription: "Failed to parse date")
            )
        })
        return decoder
    }
}
