//
//  MlemError.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-06.
//

enum MlemError: Error {
    case modelError(String)
    case navigationError(String)
    case unexpectedValue
    case cannotAccessSecurityScopedResource
}

extension MlemError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .modelError(string):
            return "Model Error: \(string)"
        case let .navigationError(string):
            return "Navigation Error: \(string)"
        case .cannotAccessSecurityScopedResource:
            return "Cannot access security-scoped resource"
        case .unexpectedValue:
            return "Encountered unexpected value"
        }
    }
}
