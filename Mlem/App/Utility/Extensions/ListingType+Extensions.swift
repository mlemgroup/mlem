//
//  ApiListingType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 29/07/2024.
//

import Foundation
import MlemMiddleware

extension ListingType {
    var label: LocalizedStringResource {
        switch self {
        case .all: "All"
        case .local: "Local"
        case .subscribed: "Subscribed"
        case .moderatorView: "Moderated"
        }
    }

    static var guestCases: [ListingType] {
        [.all, .local]
    }

    static var userCases: [ListingType] {
        [.all, .local, .subscribed]
    }

    static var moderatorCases: [ListingType] { allCases }

    static func cases(for accountType: AccountType) -> [Self] {
        switch accountType {
        case .guest: guestCases
        case .user: userCases
        case .moderator, .admin: moderatorCases
        }
    }

    var description: FeedDescription {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderatorView: .moderated
        }
    }
    
    var feedContext: FeedContext {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderatorView: .moderated
        }
    }
}
