//
//  CommunityModel.swift
//  Mlem
//
//  Created by Sjmarf on 20/09/2023.
//

import Dependencies
import SwiftUI

struct ActiveUserCount {
    let sixMonths: Int
    let month: Int
    let week: Int
    let day: Int
}

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
    
    @available(*, deprecated, message: "Use attributes of the CommunityModel directly instead.")
    var community: APICommunity!
    
    // Ids
    var communityId: Int!
    var instanceId: Int!
    
    // Text
    var name: String!
    var displayName: String!
    var description: String?
    
    // Images
    var avatar: URL?
    var banner: URL?
    
    // State
    var nsfw: Bool!
    var local: Bool!
    var removed: Bool!
    var deleted: Bool!
    var hidden: Bool!
    var postingRestrictedToMods: Bool!
    var favorited: Bool!
    
    // Dates
    var creationDate: Date!
    var updatedDate: Date?
    
    // URLs
    var communityUrl: URL!
    
    // From APICommunityView
    var blocked: Bool?
    var subscribed: Bool?
    var subscriberCount: Int?
    var localSubscriberCount: Int?
    var postCount: Int?
    var commentCount: Int?
    var activeUserCount: ActiveUserCount?
    
    // From GetCommunityResponse
    var site: APISite?
    var moderators: [UserModel]?
    var discussionLanguages: [Int]?
    var defaultPostLanguage: Int?
    
    init(from response: GetCommunityResponse) {
        self.update(with: response)
    }
    
    init(from response: CommunityResponse) {
        self.update(with: response)
    }
    
    init(from communityView: APICommunityView) {
        self.update(with: communityView)
    }
    
    init(from community: APICommunity, subscribed: Bool? = nil) {
        self.update(with: community)
        if let subscribed {
            self.subscribed = subscribed
        }
    }
    
    mutating func update(with response: CommunityResponse) {
        self.discussionLanguages = response.discussionLanguages
        self.update(with: response.communityView)
    }
    
    mutating func update(with response: GetCommunityResponse) {
        self.site = response.site
        self.moderators = response.moderators.map { UserModel(from: $0.moderator) }
        self.discussionLanguages = response.discussionLanguages
        self.defaultPostLanguage = response.defaultPostLanguage
        self.update(with: response.communityView)
    }
    
    mutating func update(with communityView: APICommunityView) {
        self.subscribed = communityView.subscribed.isSubscribed
        self.blocked = communityView.blocked
        
        self.subscriberCount = communityView.counts.subscribers
        self.localSubscriberCount = communityView.counts.subscribersLocal
        self.postCount = communityView.counts.posts
        self.commentCount = communityView.counts.comments
        self.activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )
        self.update(with: communityView.community)
    }
    
    mutating func update(with community: APICommunity) {
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
        
        @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
        self.favorited = favoriteCommunitiesTracker.isFavorited(community)
    }
    
    func toggleSubscribe(_ callback: @escaping (_ item: Self) -> Void = { _ in }) async throws {
        var new = self
        guard let subscribed, let subscriberCount else {
            throw CommunityError.noData
        }
        new.subscribed = !subscribed
        if subscribed {
            new.subscriberCount = subscriberCount - 1
            if new.favorited {
                favoriteCommunitiesTracker.unfavorite(community)
            }
        } else {
            new.subscriberCount = subscriberCount + 1
        }
        RunLoop.main.perform { [new] in
            callback(new)
        }
        do {
            let response = try await apiClient.followCommunity(id: communityId, shouldFollow: !subscribed)
            new.update(with: response)
            RunLoop.main.perform { [new] in
                callback(new)
            }
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            let phrase = (new.subscribed ?? false) ? "unsubscribe from" : "subscribe to"
            errorHandler.handle(
                .init(title: "Failed to \(phrase) community", style: .toast, underlyingError: error)
            )
        }
    }
    
    func toggleFavorite(_ callback: @escaping (_ item: Self) -> Void = { _ in }) async throws {
        var new = self
        new.favorited.toggle()
        if new.favorited {
            favoriteCommunitiesTracker.favorite(self.community)
            if let subscribed, !subscribed {
                try await new.toggleSubscribe { community in
                    var community = community
                    if !(community.subscribed ?? true) {
                        print("Subscribe failed, unfavoriting...")
                        community.favorited = false
                        favoriteCommunitiesTracker.unfavorite(community.community)
                    }
                    callback(community)
                }
            } else {
                RunLoop.main.perform { [new] in
                    callback(new)
                }
            }
        } else {
            favoriteCommunitiesTracker.unfavorite(community)
            RunLoop.main.perform { [new] in
                callback(new)
            }
        }
    }
    
    func toggleBlock(_ callback: @escaping (_ item: Self) -> Void = { _ in }) async throws {
        var new = self
        guard let blocked else {
            throw CommunityError.noData
        }
        new.blocked = !blocked
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
            new.update(with: response.communityView)
            RunLoop.main.perform { [new] in
                callback(new)
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
            return "\(name!)@\(host)"
        }
        return nil
    }
    
    func copyFullyQualifiedName() {
        let pasteboard = UIPasteboard.general
        if let fullyQualifiedName {
            pasteboard.string = "!\(fullyQualifiedName)"
            Task {
                await notifier.add(.success("Community Name Copied"))
            }
        } else {
            Task {
                await notifier.add(.failure("Failed to copy"))
            }
        }
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
