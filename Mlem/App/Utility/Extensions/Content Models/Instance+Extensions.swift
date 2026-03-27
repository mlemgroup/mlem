//
//  Instance3+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-02.
//

import Foundation
import MlemMiddleware
import MlemBackend

extension Instance {
    func slurRegex() -> Regex<AnyRegexOutput>? {
        do {
            if let regex = slurFilterRegex.value as? String {
                return try .init(regex)
            }
        } catch {
            handleError(error, silent: true)
        }
        return nil
    }
    
    var instanceSummary: InstanceSummary? {
        if let userCount = userCount.value,
           let software = software.value {
            return .init(
                displayName: displayName,
                name: name,
                totalUsers: userCount,
                avatar: avatar,
                software: .init(from: software)
            )
        }
        return nil
    }
}
