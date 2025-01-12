//
//  ModlogView+Logic.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-11.
//

import MlemMiddleware
import SwiftUI

extension ModlogView {
    enum InitialTarget: Hashable {
        case community(AnyCommunity)
        case instance(InstanceHashWrapper)
    }
    
    enum CommunityFilter: Equatable {
        case any
        case community(any Community)
        
        var label: String {
            switch self {
            case .any: .init(localized: "Any Community")
            case let .community(community): community.name
            }
        }
        
        var communityValue: (any Community)? {
            switch self {
            case let .community(community): community
            default: nil
            }
        }
        
        static func == (lhs: CommunityFilter, rhs: CommunityFilter) -> Bool {
            switch (lhs, rhs) {
            case let (.community(lhs), .community(rhs)): lhs === rhs
            case (.any, .any): true
            default: false
            }
        }
    }
    
    func refresh() async throws {
        try await feedLoader.refresh(
            api: api,
            communityId: communityFilter?.communityValue?.id,
            clearBeforeRefresh: true
        )
    }
    
    var activeFeedLoader: any FeedLoading<ModlogEntry> {
        if let actionTypeFilter {
            feedLoader.childLoader(ofType: actionTypeFilter)
        } else {
            feedLoader
        }
    }
}
