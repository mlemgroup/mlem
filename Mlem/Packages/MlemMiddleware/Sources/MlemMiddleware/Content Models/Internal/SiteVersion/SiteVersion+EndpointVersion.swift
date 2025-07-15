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
}
