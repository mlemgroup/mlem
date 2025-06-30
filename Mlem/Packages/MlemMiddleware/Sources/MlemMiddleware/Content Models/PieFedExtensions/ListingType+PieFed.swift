//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-19.
//

import Foundation

public extension ListingType {
    var pieFedListingType: PieFedListingType {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderatorView: .moderatorView
        }
    }
}
