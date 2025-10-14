//
//  File.swift
//  Actions
//
//  Created by Sjmarf on 2025-10-14.
//

import Foundation

public extension JSONDecoder {
    /// You must call this on your `JSONDecoder` before attempting to decode
    /// an `ActionToken`.
    ///
    func withActionRegistry(_ registry: ActionRegistry) {
        userInfo[.actionRegistry] = registry
    }
}

extension CodingUserInfoKey {
    static let actionRegistry = CodingUserInfoKey(rawValue: "actionRegistry")!
}
