//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public extension PieFedConnection {
    func supports(_ feature: Feature) async throws -> Bool {
        try await Self.supports(feature, version: version)
    }
    
    func supportsOrNil(_ feature: Feature) -> Bool? {
        if let fetchedVersion {
            return Self.supports(feature, version: fetchedVersion)
        } else {
            return nil
        }
    }

    static func supports(
        _ feature: Feature,
        version: SiteVersion
    ) -> Bool { false }
}
