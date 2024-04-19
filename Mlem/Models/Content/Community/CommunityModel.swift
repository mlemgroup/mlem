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

// swiftlint:disable:next type_body_length
struct CommunityModel: Purgable {
    // MARK: - Members and Init
    
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.hapticManager) var hapticManager
    @Dependency(\.communityRepository) var communityRepository
    @Dependency(\.notifier) var notifier
    @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
    @Dependency(\.siteInformation) var siteInformation
    
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
        update(with: response)
    }
    
    init(from response: CommunityResponse) {
        update(with: response)
    }
    
    init(from communityView: APICommunityView) {
        update(with: communityView)
    }
    
    init(from community: APICommunity, subscribed: Bool? = nil, blocked: Bool? = nil) {
        update(with: community)
        if let subscribed {
            self.subscribed = subscribed
        }
        if let blocked {
            self.blocked = blocked
        }
    }
    
    mutating func update(with response: CommunityResponse) {
        discussionLanguages = response.discussionLanguages
        update(with: response.communityView)
    }
    
    mutating func update(with response: GetCommunityResponse) {
        site = response.site
        moderators = response.moderators.map { UserModel(from: $0.moderator) }
        discussionLanguages = response.discussionLanguages
        defaultPostLanguage = response.defaultPostLanguage
        update(with: response.communityView)
    }
    
    mutating func update(with communityView: APICommunityView) {
        subscribed = communityView.subscribed.isSubscribed
        blocked = communityView.blocked
        subscriberCount = communityView.counts.subscribers
        localSubscriberCount = communityView.counts.subscribersLocal
        postCount = communityView.counts.posts
        commentCount = communityView.counts.comments
        activeUserCount = .init(
            sixMonths: communityView.counts.usersActiveHalfYear,
            month: communityView.counts.usersActiveMonth,
            week: communityView.counts.usersActiveWeek,
            day: communityView.counts.usersActiveDay
        )
        update(with: communityView.community)
    }
    
    mutating func update(with community: APICommunity) {
        self.community = community
        
        communityId = community.id
        instanceId = community.instanceId
        
        name = community.name
        displayName = community.title
        description = community.description
        
        avatar = community.iconUrl
        banner = community.bannerUrl
        
        nsfw = community.nsfw
        local = community.local
        removed = community.removed
        deleted = community.deleted
        hidden = community.hidden
        postingRestrictedToMods = community.postingRestrictedToMods
        
        creationDate = community.published
        updatedDate = community.updated
        
        communityUrl = community.actorId
        
        @Dependency(\.favoriteCommunitiesTracker) var favoriteCommunitiesTracker
        favorited = favoriteCommunitiesTracker.isFavorited(community)
    }
    
    // MARK: - Convenience
    
    func isModerator(_ userId: Int?) -> Bool {
        if let moderators, let userId {
            return moderators.contains(where: { userModel in
                userModel.userId == userId
            })
        }
        return false
    }
    
    // MARK: - Interactions
    
    func toggleSubscribe(_ callback: @escaping (_ item: Self) -> Void = { _ in }) async throws {
        var new = self
        guard let subscribed, let subscriberCount else {
            throw CommunityError.noData
        }
        new.subscribed = !subscribed
        if subscribed {
            new.subscriberCount = subscriberCount - 1
            if new.favorited {
                favoriteCommunitiesTracker.unfavorite(communityId)
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
            favoriteCommunitiesTracker.favorite(community)
            if let subscribed, !subscribed {
                try await new.toggleSubscribe { community in
                    var community = community
                    if !(community.subscribed ?? true) {
                        print("Subscribe failed, unfavoriting...")
                        community.favorited = false
                        favoriteCommunitiesTracker.unfavorite(communityId)
                    }
                    callback(community)
                }
            } else {
                RunLoop.main.perform { [new] in
                    callback(new)
                }
            }
        } else {
            favoriteCommunitiesTracker.unfavorite(communityId)
            RunLoop.main.perform { [new] in
                callback(new)
            }
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
            let response: BlockCommunityResponse
            if !blocked {
                response = try await communityRepository.blockCommunity(id: communityId)
            } else {
                response = try await communityRepository.unblockCommunity(id: communityId)
            }
            self.update(with: response.communityView)
            RunLoop.main.perform { [self] in
                callback(self)
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
    
    // MARK: - Moderation
    
    func toggleRemove(
        reason: String?,
        callback: @escaping (_ item: Self) -> Void = { _ in },
        onFailure: () -> Void
    ) async {
        // no need to state fake because removal masked by sheet
        do {
            let response = try await apiClient.removeCommunity(
                id: communityId,
                shouldRemove: !removed,
                reason: reason
            )
            callback(.init(from: response))
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
    }
    
    func purge(reason: String?) async -> Bool {
        do {
            let response = try await apiClient.purgeCommunity(id: communityId, reason: reason)
            if !response.success {
                throw APIClientError.unexpectedResponse
            }
            return true
        } catch {
            hapticManager.play(haptic: .failure, priority: .high)
            errorHandler.handle(error)
        }
        return false
    }
    
    func banUser(
        userId: Int,
        ban: Bool,
        removeData: Bool? = nil,
        reason: String? = nil,
        expires: Int? = nil
    ) async -> Bool {
        do {
            let updatedBannedStatus = try await apiClient.banFromCommunity(
                userId: userId,
                communityId: communityId,
                ban: ban,
                removeData: removeData,
                reason: reason,
                expires: expires
            )
            return updatedBannedStatus
        } catch {
            errorHandler.handle(error)
            return !ban
        }
    }
    
    /// Updates mod status of the given user in this community and updates the mod list
    /// - Parameters:
    ///   - of: id of the user to change mod status of
    ///   - to: new mod status
    /// - Returns: true on successful update, false otherwise
    func updateModStatus(of userId: Int, to status: Bool, callback: @escaping (_ item: Self) -> Void = { _ in }) async -> Bool {
        var new = self
        do {
            let newModerators = try await apiClient.updateModStatus(of: userId, in: communityId, status: status)
            new.moderators = newModerators
            RunLoop.main.perform { [new] in
                callback(new)
            }
            return true
        } catch {
            errorHandler.handle(error)
            return false
        }
    }
    
    // MARK: - Misc
    
    var fullyQualifiedNameComponents: (String, String)? {
        if let host = communityUrl.host() {
            return (name!, host)
        }
        return nil
    }
    
    var fullyQualifiedName: String? {
        if let host = communityUrl.host() {
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
        .init(from: GetCommunityResponse.mock())
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
        hasher.combine(removed)
        hasher.combine(moderators?.map(\.id) ?? [])
    }
}
