//
//  Parse JSON.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import SwiftyJSON

enum JSONParsingError: Error
{
    case failedToConvertToData, failedToParse
}

func parseJSON(from string: String) throws -> JSON
{
    if let dataFromString = string.data(using: .utf8, allowLossyConversion: false)
    {
        do
        {
            let parsedJSON: JSON = try JSON(data: dataFromString)

            return parsedJSON
        }
        catch let decodingError as NSError
        {
            print("Failed while decoding JSON: \(decodingError)")
            throw JSONParsingError.failedToParse
        }
    }
    else
    {
        print("Failed to convert String to Data")
        throw JSONParsingError.failedToConvertToData
    }
}
