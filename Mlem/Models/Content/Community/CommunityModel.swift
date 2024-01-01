//
//  CommunityModel.swift
//  Mlem
//
//  Created by Sjmarf on 20/09/2023.
//

import Dependencies
import Foundation

struct CommunityModel {
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.notifier) var notifier
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    
    enum CommunityError: Error {
        case noData
    }
    
    struct ActiveUserCount {
        let sixMonths: Int
        let month: Int
        let week: Int
        let day: Int
    }
    
    @available(*, deprecated, message: "Use attributes of the CommunityModel directly instead.")
    var community: APICommunity
    
    // Ids
    let communityId: Int
    let instanceId: Int
    
    // Text
    let name: String
    let displayName: String
    let description: String?
    
    // Images
    let avatar: URL?
    let banner: URL?
    
    // State
    var nsfw: Bool
    var local: Bool
    var removed: Bool
    var deleted: Bool
    var hidden: Bool
    var postingRestrictedToMods: Bool
    var favorited: Bool
    
    // Dates
    let creationDate: Date
    let updatedDate: Date?
    
    // URLs
    let communityUrl: URL
    
    // From APICommunityView
    var blocked: Bool?
    var subscribed: Bool?
    var subscriberCount: Int?
    var postCount: Int?
    var commentCount: Int?
    var activeUserCount: ActiveUserCount?
    
    // From GetCommunityResponse
    var site: APISite?
    var moderators: [UserModel]?
    var discussionLanguages: [Int]?
    var defaultPostLanguage: Int?
    
    init(from response: GetCommunityResponse) {
        self.init(from: response.communityView)
        self.site = response.site
        self.moderators = response.moderators.map { UserModel(from: $0.moderator) }
        self.discussionLanguages = response.discussionLanguages
        self.defaultPostLanguage = response.defaultPostLanguage
    }
    
    init(from response: CommunityResponse) {
        self.init(from: response.communityView)
        self.discussionLanguages = response.discussionLanguages
    }
    
    init(from communityView: APICommunityView) {
        self.init(from: communityView.community)
        self.subscribed = communityView.subscribed.isSubscribed
        self.blocked = communityView.blocked
        
        self.subscriberCount = communityView.counts.subscribers
        self.postCount = communityView.counts.posts
        self.commentCount = communityView.counts.comments
        self.activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )
    }
    
    init(from community: APICommunity, subscribed: Bool? = nil) {
        self.community = community
        
        self.communityId = community.id
        self.instanceId = community.instanceId
        
        self.name = community.name
        self.displayName = community.title
        self.description = community.description
        
        self.avatar = community.iconUrl
        self.banner = community.bannerUrl
        
        self.nsfw = community.nsfw
        self.local = community.local
        self.removed = community.removed
        self.deleted = community.deleted
        self.hidden = community.hidden
        self.postingRestrictedToMods = community.postingRestrictedToMods
        
        self.creationDate = community.published
        self.updatedDate = community.updated
        
        self.communityUrl = community.actorId
        
        self.subscribed = subscribed
        
        @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
        self.favorited = favoriteCommunitiesTracker.isFavorited(community)
    }
    
    mutating func toggleSubscribe(_ callback: @escaping (_ item: Self) -> Void = { _ in }) async throws {
        guard let subscribed, let subscriberCount else {
            throw CommunityError.noData
        }
        self.subscribed = !subscribed
        if subscribed {
            self.subscriberCount = subscriberCount - 1
        } else {
            self.subscriberCount = subscriberCount + 1
        }
        RunLoop.main.perform { [self] in
            callback(self)
        }
        do {
            let response = try await apiClient.followCommunity(id: communityId, shouldFollow: !subscribed)
            RunLoop.main.perform {
                callback(CommunityModel(from: response))
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            let phrase = (self.subscribed ?? false) ? "unsubscribe from" : "subscribe to"
            errorHandler.handle(
                .init(title: "Failed to \(phrase) community", style: .toast, underlyingError: error)
            )
        }
    }
    
    mutating func toggleFavorite(_ callback: @escaping (_ item: Self) -> Void = { _ in }) {
        if favorited {
            favoriteCommunitiesTracker.unfavorite(community)
        } else {
            favoriteCommunitiesTracker.favorite(community)
        }
        self.favorited.toggle()
        callback(self)
    }
    
    mutating func toggleBlock(_ callback: @escaping (_ item: Self) -> Void = { _ in }) async throws {
        guard let blocked else {
            throw CommunityError.noData
        }
        self.blocked = !blocked
        RunLoop.main.perform { [self] in
            callback(self)
        }
        do {
            let response: BlockCommunityResponse
            if !blocked {
                response = try await communityRepository.blockCommunity(id: communityId)
            } else {
                response = try await communityRepository.unblockCommunity(id: communityId)
            }
            RunLoop.main.perform {
                callback(CommunityModel(from: response.communityView))
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
            let phrase = !blocked ? "block" : "unblock"
            errorHandler.handle(
                .init(title: "Failed to \(phrase) community", style: .toast, underlyingError: error)
            )
        }
    }
    
    var fullyQualifiedName: String? {
        if let host = self.communityUrl.host() {
            return "@\(name)@\(host)"
        }
        return nil
    }
    
    static func mock() -> CommunityModel {
        return .init(from: GetCommunityResponse.mock())
    }
}

extension CommunityModel: Identifiable {
    var id: Int { hashValue }
}

extension CommunityModel: Hashable {
    static func == (lhs: CommunityModel, rhs: CommunityModel) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(subscribed)
        hasher.combine(favorited)
        hasher.combine(subscriberCount)
        hasher.combine(blocked)
        hasher.combine(moderators?.map(\.id) ?? [])
    }
}
