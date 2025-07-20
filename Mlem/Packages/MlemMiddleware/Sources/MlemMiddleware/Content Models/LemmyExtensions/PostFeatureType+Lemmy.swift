//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-20.
//

import Foundation

extension PostFeatureType {
    var apiType: LemmyPostFeatureType {
        switch self {
        case .community: .community
        case .instance: .local
        }
    }
}
