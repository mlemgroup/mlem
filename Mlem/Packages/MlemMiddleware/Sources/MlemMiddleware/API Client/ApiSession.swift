//
//  ApiSession.swift
//  Mlem
//
//  Created by mormaer on 02/09/2023.
//
//

import Foundation

enum ApiSessionError: Error {
    case authenticationNotPresent
    case undefined
}

/// An enumeration representing possible session states
enum ApiSession {
    case authenticated(URL, String)
    case unauthenticated(URL)
    case undefined
    
    var token: String {
        get throws {
            guard case let .authenticated(_, token) = self else {
                throw ApiSessionError.authenticationNotPresent
            }
            
            return token
        }
    }
    
    var instanceUrl: URL {
        get throws {
            switch self {
            case let .authenticated(url, _):
                return url
            case let .unauthenticated(url):
                return url
            case .undefined:
                throw ApiSessionError.undefined
            }
        }
    }
}
