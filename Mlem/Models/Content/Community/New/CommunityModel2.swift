//
//  CommunityModel2.swift
//  Mlem
//
//  Created by Sjmarf on 02/02/2024.
//

import Dependencies
import SwiftUI
import Observation

enum SubscriptionStatus {
    case unsubscribed, subscribed, favorited
}

@Observable
final class CommunityModel2 {
    let community1: CommunityModel1
    let published: Date

    // These aren't settable from outside
    private(set) var subscriberCount: Int
    private(set) var postCount: Int
    private(set) var commentCount: Int
    private(set) var activeUserCount: ActiveUserCount

    // These will be settable in future
    private(set) var subscriptionStatus: SubscriptionStatus
    private(set) var blocked: Bool

    // Computed
    var subscribed: Bool { subscriptionStatus == .subscribed }
    var favorited: Bool { subscriptionStatus != .unsubscribed }
}

extension CommunityModel2: CommunityModelProto {
    var communityId: Int { community1.communityId }
    var creationDate: Date { community1.creationDate }
    var actorId: URL { community1.actorId }
    var local: Bool { community1.local }

    var updatedDate: Date { community1.updatedDate }

    var name: String { community1.name }
    var displayName: String { community1.displayName }
    var removed: Bool { community1.removed }
    var deleted: Bool { community1.deleted }
    var nsfw: Bool { community1.nsfw }
    var avatarURL: URL? { community1.avatarURL }
    var bannerURL: URL? { community1.bannerURL }
    var onlyModeratorsCanPost: Bool { community1.onlyModeratorsCanPost }
    var hidden: Bool { community1.hidden }
}

extension CommunityModel2: NewContentModel {
    static var cache: ContentCache<CommunityModel2> = .init()
    typealias APIType = APICommunityView

    required init(from communityView: APICommunityView) {
        subscriberCount = communityView.counts.subscriberCount
        postCount = communityView.counts.posts
        commentCount = communityView.counts.comments
        activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )

        subscriptionStatus = communityView.subscribed ? .subscribed : .unsubscribed
        blocked = communityView.blocked

        community1 = CommunityModel1.cache.createModel(for: communityView.community)
    }
}