//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension ListingType {
    init?(from listingType: PieFedListingType) {
        let value: Self? = switch listingType {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderatorView: .moderated
        case .popular: nil
        }
        if let value {
            self = value
        } else {
            return nil
        }
    }
    
    var pieFedListingType: PieFedListingType {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderated: .moderatorView
        }
    }
}
