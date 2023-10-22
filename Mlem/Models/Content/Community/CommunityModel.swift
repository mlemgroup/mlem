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
    
    enum CommunityError: Error {
        case noData
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
    
    // From APICommunityView
    var blocked: Bool?
    var subscribed: Bool?
    var subscriberCount: Int?
    
    // Dates
    let creationDate: Date
    let updatedDate: Date?
    
    // URLs
    let communityUrl: URL
    
    // These values are only available via GetCommunityResponse
    var site: APISite?
    var moderators: [APICommunityModeratorView]?
    var discussionLanguages: [Int]?
    var defaultPostLanguage: Int?
    
    init(from response: GetCommunityResponse) {
        self.init(from: response.communityView)
        self.site = response.site
        self.moderators = response.moderators
        self.discussionLanguages = response.discussionLanguages
        self.defaultPostLanguage = response.defaultPostLanguage
    }
    
    init(from communityView: APICommunityView) {
        self.init(from: communityView.community)
        self.subscriberCount = communityView.counts.subscribers
        self.subscribed = communityView.subscribed != .notSubscribed ? true : false
        self.blocked = communityView.blocked
    }
    
    init(from community: APICommunity) {
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
    }
    
    mutating func toggleSubscribe(_ callback: @escaping (_ item: Self) -> Void = { _ in }) async throws {
        guard let subscribed, let subscriberCount else {
            throw CommunityError.noData
        }
        self.subscribed = !subscribed
        if subscribed {
            self.subscriberCount = subscriberCount + 1
        } else {
            self.subscriberCount = subscriberCount - 1
        }
        RunLoop.main.perform { [self] in
            callback(self)
        }
        do {
            try await apiClient.followCommunity(id: communityId, shouldFollow: !subscribed)
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            let phrase = (self.subscribed ?? false) ? "unsubscribe from" : "subscribe to"
            errorHandler.handle(
                .init(title: "Failed to \(phrase) community", style: .toast, underlyingError: error)
            )
        }
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
            if !blocked {
                try await communityRepository.blockCommunity(id: communityId)
            } else {
                try await communityRepository.unblockCommunity(id: communityId)
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
}

extension CommunityModel: Identifiable {
    var id: Int { hashValue }
}

extension CommunityModel: Hashable {
    static func == (lhs: CommunityModel, rhs: CommunityModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    /// Hashes all fields for which state changes should trigger view updates.
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
        hasher.combine(subscribed)
        hasher.combine(subscriberCount)
        hasher.combine(blocked)
        hasher.combine(moderators?.map { $0.moderator.id } ?? [])
    }
}
