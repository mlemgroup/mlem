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
        case community(Community)
        case instance(InstanceHashWrapper)
        case currentInstance
    }
    
    enum CommunityFilter: Hashable {
        case any
        case community(Community)
        
        var label: String {
            switch self {
            case .any: .init(localized: "Any Community")
            case let .community(community): community.name
            }
        }
        
        var communityValue: Community? {
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

        func hash(into hasher: inout Hasher) {
            hasher.combine(communityValue?.api.cacheId)
            hasher.combine(communityValue?.id)
        }
    }

    enum PersonFilter: Hashable {
        case any
        case person(Person)

        var label: String {
            switch self {
            case .any: .init(localized: "Any User")
            case let .person(person): person.name
            }
        }

        var personValue: (Person)? {
            switch self {
            case let .person(person): person
            default: nil
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.person(lhs), .person(rhs)): lhs === rhs
            case (.any, .any): true
            default: false
            }
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(personValue?.api.cacheId)
            hasher.combine(personValue?.id)
        }
    }
    
    func refresh() async throws {
        try await feedLoader.refresh(
            api: api,
            communityId: communityFilter?.communityValue?.id,
            targetPersonId: targetPersonFilter.personValue?.id,
            moderatorPersonId: moderatorPersonFilter.personValue?.id,
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

    var refreshHashValue: Int {
        var hasher = Hasher()
        hasher.combine(communityFilter)
        hasher.combine(targetPersonFilter)
        hasher.combine(moderatorPersonFilter)
        return hasher.finalize()
    }
}
