//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-24.
//

import Foundation

public enum UsernameValidity: Hashable, Sendable {
    case available
    case taken
    case invalid(InvalidityReason)
    
    public enum InvalidityReason: Hashable, Sendable {
        case tooShort(minLength: Int)
        case tooLong(maxLength: Int)
        case containsInvalidCharacters(_ characters: Set<Character>)
        case other
    }
}
