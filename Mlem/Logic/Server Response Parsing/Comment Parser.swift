//
//  Comment Parses.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import Foundation
import SwiftyJSON

func parseComments(commentResponse: String) async throws -> [Comment]
{
    let commentTracker: [Comment] = .init()
    
    do
    {
        let parsedJSON: JSON = try parseJSON(from: commentResponse)
    }
    catch let parsingError
    {
        print("Failed while parsing comment JSON: \(parsingError)")
        throw JSONParsingError.failedToParse
    }
    
    return commentTracker
}

