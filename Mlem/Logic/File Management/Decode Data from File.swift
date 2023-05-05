//
//  Decode Data from File.swift
//  Mlem
//
//  Created by David Bureš on 05.05.2023.
//

import Foundation

internal enum DecodingError: Error
{
    case failedtoReadFile, failedToDecode
}

func decodeCommunitiesFromFile(fromURL: URL) throws -> [SavedCommunity]
{
    do
    {
        let rawData: Data = try Data(contentsOf: fromURL, options: .mappedIfSafe)
        
        do
        {
            return try JSONDecoder().decode([SavedCommunity].self, from: rawData)
        }
        catch let decodingError
        {
            print("Failed to decode loaded data: \(decodingError.localizedDescription)")
            throw DecodingError.failedToDecode
        }
    }
    catch let fileReadingError
    {
        print("Failed to load data from file: \(fileReadingError.localizedDescription)")
        throw DecodingError.failedtoReadFile
    }
}
