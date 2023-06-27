//
//  Decode Data from File.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

internal enum DecodingError: Error {
    case failedtoReadFile, failedToDecode
}

internal enum WhatToDecode {
    case accounts, filteredKeywords, favoriteCommunities
}

func decodeFromFile(fromURL: URL, whatToDecode: WhatToDecode) throws -> any Codable {
    do {
        let rawData: Data = try Data(contentsOf: fromURL, options: .mappedIfSafe)

        do {
            switch whatToDecode {
            case .accounts:
                return try JSONDecoder().decode([SavedAccount].self, from: rawData)
            case .filteredKeywords:
                return try JSONDecoder().decode([String].self, from: rawData)
            case .favoriteCommunities:
                return try JSONDecoder().decode([FavoriteCommunity].self, from: rawData)
            }
        } catch let decodingError {
            print("Failed to decode loaded data: \(decodingError.localizedDescription)")
            throw DecodingError.failedToDecode
        }
    } catch let fileReadingError {
        print("Failed to load data from file: \(fileReadingError.localizedDescription)")
        throw DecodingError.failedtoReadFile
    }
}
