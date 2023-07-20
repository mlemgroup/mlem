//
//  Decode Data from File.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

internal enum WhatToDecode {
    case accounts, filteredKeywords, favoriteCommunities, recentSearches, easterFlags
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
            case .recentSearches:
                return try JSONDecoder().decode([String].self, from: rawData)
            case .easterFlags:
                return try JSONDecoder().decode(Set<String>.self, from: rawData)
            }
        } catch let decodingError {
            throw decodingError
        }
    } catch let fileReadingError {
        throw fileReadingError
    }
}
