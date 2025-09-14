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
        case .moderated: "Moderated"
        case .popular: "Popular"
        case .suggested: "Suggested"
        }
    }

    static var guestCases: [ListingType] {
        [.all, .local, .popular]
    }

    static var userCases: [ListingType] {
        [.all, .local, .popular, .suggested, .subscribed]
    }

    static var moderatorCases: [ListingType] { allCases }

    static func cases(for accountType: AccountType, api: ApiClient) -> [Self] {
        let cases = switch accountType {
        case .guest: guestCases
        case .user: userCases
        case .moderator, .admin: moderatorCases
        }
        return cases.filter { api.supports(.listingType($0), defaultValue: false) }
    }

    var description: FeedDescription {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderated: .moderated
        case .popular: .popular
        case .suggested: .suggested
        }
    }
    
    var feedContext: FeedContext {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .moderated: .moderated
        case .popular: .popular
        case .suggested: .suggested
        }
    }
}
