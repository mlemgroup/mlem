//
//  APISession.swift
//  Mlem
//
//  Created by mormaer on 02/09/2023.
//
//

import Foundation

enum APISessionError: Error {
    case authenticationNotPresent
    case undefined
}

/// An enumeration representing possible session states
enum APISession {
    case authenticated(URL, String)
    case unauthenticated(URL)
    case undefined
    
    var token: String {
        get throws {
            guard case let .authenticated(_, token) = self else {
                throw APISessionError.authenticationNotPresent
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
                throw APISessionError.undefined
            }
        }
    }
}
