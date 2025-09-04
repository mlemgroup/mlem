//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension ListingType {
    init(from type: LemmyListingType) throws(ApiClientError) {
        let value: Self? = switch type {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderatorView: .moderated
        case .suggested: .suggested
        }
        
        guard let value else {
            throw .featureUnsupported
        }
        
        self = value
    }
    
    var apiType: LemmyListingType? {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderated: .moderatorView
        case .popular: nil
        case .suggested: .suggested
        }
    }
}
