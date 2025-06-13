//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public enum PostFeatureType {
    case community, instance
    
    init(from featureType: ApiPostFeatureType) {
        self = switch featureType {
        case .community: .community
        case .local: .instance
        }
    }
    
    var apiType: ApiPostFeatureType {
        switch self {
        case .community: .community
        case .instance: .local
        }
    }
}
