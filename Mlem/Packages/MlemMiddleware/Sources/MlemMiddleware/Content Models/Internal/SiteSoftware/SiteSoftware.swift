//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation
import MlemBackend

public struct SiteSoftware: Codable, Hashable {
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

public extension InstanceSummarySoftware {
    init(from software: SiteSoftware) {
        let type: InstanceSummarySoftwareType = switch software.type {
        case .lemmy: .lemmy
        case .pieFed: .piefed
        }
        
        self.init(
            type: type,
            version: software.version.description
        )
    }
}
