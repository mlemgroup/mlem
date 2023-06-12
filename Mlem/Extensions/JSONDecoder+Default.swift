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
        
        decoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            
            formatter.timeZone = .gmt
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            if let date = formatter.date(from: string) {
                return date
            }
            
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            if let date = formatter.date(from: string) {
                return date
            }
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSS"
            if let date = formatter.date(from: string) {
                return date
            }
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            if let date = formatter.date(from: string) {
                return date
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
