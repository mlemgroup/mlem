//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public struct SiteSoftware: Codable, Hashable, Sendable {
    public let type: SiteSoftwareType
    public let version: SiteVersion
    
    public init(type: SiteSoftwareType, version: SiteVersion) {
        self.type = type
        self.version = version
    }
    
    public func supports(_ feature: Feature) -> Bool {
        switch type {
        case .lemmy: LemmyConnection.supports(feature, version: version)
        case .pieFed: PieFedConnection.supports(feature, version: version)
        }
    }
}

