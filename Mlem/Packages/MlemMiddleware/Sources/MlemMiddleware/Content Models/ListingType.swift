//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-11.
//

import Foundation

public enum ListingType {
    case all, local, subscribed, moderatorView
    
    init(from type: LemmyListingType) {
        self = switch type {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderatorView: .moderatorView
        }
    }
    
    var apiType: LemmyListingType {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderatorView: .moderatorView
        }
    }
}
