//
//  FeedSelection.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-12.
//

import Foundation
import MlemMiddleware

enum FeedSelection: String, CaseIterable, Codable {
    case all, local, subscribed, saved, moderated
    
    /// Feeds that can be used by a guest account
    static var guestCases: [FeedSelection] {
        [.all, .local]
    }
    
    /// Feeds that can be used by an authenticated, non-moderator account
    static var userCases: [FeedSelection] {
        [.all, .local, .subscribed, .saved]
    }
    
    /// Feeds that can be used by a moderator account
    static var moderatorCases: [FeedSelection] {
        allCases
    }
    
    static func cases(for accountType: AccountType) -> [Self] {
        switch accountType {
        case .guest: guestCases
        case .user: userCases
        case .moderator: moderatorCases
        }
    }
    
    var description: FeedDescription {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .saved: .saved
        case .moderated: .moderated
        }
    }
    
    var associatedApiType: ApiListingType {
        switch self {
        case .all: .all
        case .local: .local
        case .subscribed: .subscribed
        case .saved: .all
        case .moderated: .moderatorView
        }
    }
}
