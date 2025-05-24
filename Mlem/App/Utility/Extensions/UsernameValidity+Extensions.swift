//
//  UsernameValidity+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-05-24.
//

import Foundation
import MlemMiddleware

extension UsernameValidity {
    var label: LocalizedStringResource {
        switch self {
        case .available: "Available"
        case .taken: "Username is taken."
        case let .invalid(reason): reason.label
        }
    }
}

extension UsernameValidity.InvalidityReason {
    var label: LocalizedStringResource {
        switch self {
        case let .tooShort(minLength: minLength):
            return "Username must be at least \(minLength) characters long."
        case let .tooLong(maxLength: maxLength):
            return "Username cannot be longer than \(maxLength) characters."
        case let .containsInvalidCharacters(characters):
            let characterList = characters.map { "\"\($0)\"" }.formatted(.list(type: .or))
            return "Username cannot contain \(characterList)."
        case .other:
            return "Username is invalid."
        }
    }
}
