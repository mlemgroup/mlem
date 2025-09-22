//
//  SiteVersion+EndpointVersion.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-21.
//

import Foundation

enum LemmyEndpointVersion: Hashable, Sendable {
    case v3, v4
    
    var pathComponent: String {
        switch self {
        case .v3: "v3"
        case .v4: "v4"
        }
    }
}
