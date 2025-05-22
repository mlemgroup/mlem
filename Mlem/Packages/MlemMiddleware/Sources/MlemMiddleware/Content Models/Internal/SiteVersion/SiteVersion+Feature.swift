//
//  SiteVersion+Feature.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-21.
//

import Foundation

public extension SiteVersion {
    enum Feature {
        var minimumVersion: SiteVersion {
            switch self {
            default: .v0_19_0
            }
        }
    }
    
    /// Checks whether this SiteVersion supports the given feature. Always returns false if version unknown.
    func suppports(_ feature: Feature) -> Bool {
        switch self {
        case .other: false
        default: feature.minimumVersion <= self
        }
    }
}
