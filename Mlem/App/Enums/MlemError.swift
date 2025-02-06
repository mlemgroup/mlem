//
//  MlemError.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-02-06.
//

enum MlemError: Error {
    case modelError(String)
}

extension MlemError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .modelError(string):
            return "Model Error: \(string)"
        }
    }
}
