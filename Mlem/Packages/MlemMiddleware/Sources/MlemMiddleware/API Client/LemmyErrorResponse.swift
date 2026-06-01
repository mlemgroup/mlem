//
//  LemmyErrorResponse.swift
//  Mlem
//
//  Created by Nicholas Lawson on 06/06/2023.
//

import Foundation

// TODO: 0.19 support add all the error types (https://github.com/LemmyNet/lemmy-js-client/blob/b2edfeeaffd189a51150362cc8ead03c65ee2652/src/types/LemmyErrorType.ts)

public struct LemmyErrorResponse: Decodable, CustomStringConvertible {
    public let error: String
    
    public var description: String { error }
}

