//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-11.
//

import Foundation

public enum ListingType {
    case all, local, subscribed, moderatorView
    
    init(from type: ApiListingType) {
        self = switch type {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderatorView: .moderatorView
        }
    }
    
    var apiType: ApiListingType {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderatorView: .moderatorView
        }
    }
}
