//
//  CommunityTier2.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Dependencies
import Observation
import SwiftUI

protocol CommunityTier2Providing: CommunityTier1Providing {
    var subscriberCount: Int { get }
    var postCount: Int { get }
    var commentCount: Int { get }
    var activeUserCount: ActiveUserCount { get }
}

@Observable
final class CommunityTier2: CommunityTier2Providing, DependentContentModel {
    typealias APIType = APICommunityView
    var source: any APISource
    
    // Forward properties from CommunityTier1
    var id: Int { community1.id }
    var name: String { community1.name }
    var creationDate: Date { community1.creationDate }
    var actorID: URL { community1.actorID }
    var local: Bool { community1.local }
    var updatedDate: Date? { community1.updatedDate }
    var displayName: String { community1.displayName }
    var description: String? { community1.description }
    var removed: Bool { community1.removed }
    var deleted: Bool { community1.deleted }
    var nsfw: Bool { community1.nsfw }
    var avatar: URL? { community1.avatar }
    var banner: URL? { community1.banner }
    var hidden: Bool { community1.hidden }
    var onlyModeratorsCanPost: Bool { community1.onlyModeratorsCanPost }
    
    let community1: CommunityTier1

    private(set) var subscriberCount: Int
    private(set) var postCount: Int
    private(set) var commentCount: Int
    private(set) var activeUserCount: ActiveUserCount

    required init(source: any APISource, from communityView: APICommunityView) {
        self.source = source
        
        subscriberCount = communityView.counts.subscribers
        postCount = communityView.counts.posts
        commentCount = communityView.counts.comments
        activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )

        community1 = source.caches.community1.createModel(source: source, for: communityView.community)
    }
    
    func update(with communityView: APICommunityView) {
        subscriberCount = communityView.counts.subscribers
        postCount = communityView.counts.posts
        commentCount = communityView.counts.comments
        activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )
        community1.update(with: communityView.community)
    }
}
