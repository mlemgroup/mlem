//
//  Search Parser.swift
//  Mlem
//
//  Created by David Bureš on 16.05.2023.
//

import Foundation
import SwiftyJSON

func parseSearchResult(searchResponse: String) throws -> [Community]
{
    var communityTracker: [Community] = .init()
    
    do
    {
        let parsedFoundCommunities: JSON = try parseJSON(from: searchResponse)
    }
    catch let parsingError
    {
        print("Failed while parsing search JSON: \(parsingError)")
        throw JSONParsingError.failedToParse
    }
}
