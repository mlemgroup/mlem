//
//  SiteVersion+EndpointVersion.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-21.
//

import Foundation

public extension SiteVersion {
    enum EndpointVersion: Hashable, Sendable {
        case v3, v4
        
        public var pathComponent: String {
            switch self {
            case .v3: "v3"
            case .v4: "v4"
            }
        }
    }
    
    var supportedEndpointVersions: Set<EndpointVersion> {
        switch self {
        case .other: [.v3] // To be safe, don't allow v4
        default: self >= .v1_0_0 ? [.v3, .v4] : [.v3]
        }
    }
    
    var highestSupportedEndpointVersion: EndpointVersion {
        switch self {
        case .other: .v3
        default: self >= .v1_0_0 ? .v4 : .v3
        }
    }
}
