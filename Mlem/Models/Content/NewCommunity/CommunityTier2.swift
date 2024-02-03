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
    var subscribed: Bool { get }
    var blocked: Bool { get }
    
    func toggleSubscribed() async throws
    func toggleBlocked() async throws
}

@Observable
final class CommunityTier2: CommunityTier2Providing, NewContentModel {
    @ObservationIgnored @Dependency(\.apiClient) var apiClient
    @ObservationIgnored @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    
    // NewContentModel conformance
    static var cache: ContentCache<CommunityTier2> = .init()
    typealias APIType = APICommunityView
    
    // Forward properties from CommunityStub
    var contentId: Int { community1.contentId }
    
    // Forward properties from CommunityTier1
    var communityId: Int { community1.communityId }
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
    private(set) var blocked: Bool
    private(set) var subscribed: Bool
    
    required init(from communityView: APICommunityView) {
        subscriberCount = communityView.counts.subscribers
        postCount = communityView.counts.posts
        commentCount = communityView.counts.comments
        activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )

        subscribed = communityView.subscribed.isSubscribed
        blocked = communityView.blocked

        community1 = CommunityTier1.cache.createModel(for: communityView.community)
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

        subscribed = communityView.subscribed.isSubscribed
        blocked = communityView.blocked
        community1.update(with: communityView.community)
    }
    
    func toggleSubscribed() async throws {
        subscribed.toggle()
        do {
            let response = try await apiClient.followCommunity(id: communityId, shouldFollow: subscribed)
            update(with: response.communityView)
        } catch {
            subscribed.toggle()
            throw error
        }
    }
    
    func toggleBlocked() async throws {
        blocked.toggle()
        do {
            let response = try await apiClient.blockCommunity(id: communityId, shouldBlock: blocked)
            update(with: response.communityView)
        } catch {
            blocked.toggle()
            throw error
        }
    }
}
