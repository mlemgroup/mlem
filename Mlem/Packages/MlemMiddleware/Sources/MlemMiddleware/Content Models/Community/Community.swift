//
//  Community.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-02-14.
//

import Observation
import Foundation

public enum SubscriptionTier {
    case unsubscribed, subscribed, favorited
}

@Observable
public final class Community:
    UnifiedModelProviding,
    Profile2Providing,
    CommunityOrPerson,
    Blockable,
    ContentIdentifiable,
    RemovableProviding,
    PurgableProviding,
    Sharable,
    FeedLoadable {
    public typealias Properties = CommunityProperties
    
    public var api: ApiClient
    private let properties: CommunityProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<Community> = .init(parent: self, properties: properties)
    
    // MARK: Custom Properties
    // Mlem-specific properties that are not reflected in the API
    
    public var blocked: Bool
    public var removedPending: Bool = false
    public var purged: Bool = false
    /// Used to state-fake internally.
    public var shouldBeFavorited: Bool = false
    
    // MARK: API Properties
    // Properties that are provided by the API
    
    public let actorId: ActorIdentifier
    public let id: Int
    public let name: String
    public let created: Date
    public let instanceId: Int
    public var updated: Date?
    public var displayName: String
    public var description: String?
    public var deleted: Bool
    public var removed: Bool
    public var nsfw: Bool
    public var avatar: URL?
    public var banner: URL?
    public var hidden: Bool
    public var onlyModeratorsCanPost: Bool

    public var subscription: ExpectedValue<SubscriptionModel>
    public var postCount: ExpectedValue<Int>
    public var commentCount: ExpectedValue<Int>
    public var activeUserCount: ExpectedValue<ActiveUserCount>
    public var bannedFromCommunity: ExpectedValue<Bool?>
    public var instance: ExpectedValue<(any Instance1Providing)?>
    public var moderators: ExpectedValue<[Person]>
    public var discussionLanguageIds: ExpectedValue<Set<Int>>
    
    // MARK: Initializers and Updates
    
    public init(api: ApiClient, properties: CommunityProperties) {
        self.api = api
        self.properties = properties
        self.blocked = api.blocks?.communities.keys.contains(properties.actorId) ?? false
        
        self.actorId = properties.actorId
        self.id = properties.id
        self.name = properties.name
        self.created = properties.created
        self.instanceId = properties.instanceId
        self.updated = properties.updated
        self.displayName = properties.displayName
        self.description = properties.description
        self.deleted = properties.deleted
        self.removed = properties.removed
        self.nsfw = properties.nsfw
        self.avatar = properties.avatar
        self.banner = properties.banner
        self.hidden = properties.hidden
        self.onlyModeratorsCanPost = properties.onlyModeratorsCanPost
        
        // because upgrade() is not available until all properties are initialized, first populate all properties
        // with ExpectedValues that don't actually do anything, then reassign them properly at the end of the init
        // this is somewhat cumbersome but avoids lazy vars, which are very awkward in Observables
        self.subscription = dummyExpectedValue(properties.subscription)
        self.postCount = dummyExpectedValue(properties.postCount)
        self.commentCount = dummyExpectedValue(properties.commentCount)
        self.activeUserCount = dummyExpectedValue(properties.activeUserCount)
        self.bannedFromCommunity = dummyExpectedValue(properties.bannedFromCommunity)
        self.instance = dummyExpectedValue(properties.instance)
        self.moderators = dummyExpectedValue(properties.moderators)
        self.discussionLanguageIds = dummyExpectedValue(properties.discussionLanguageIds)
        
        func expectedValue<T>(_ value: T?) -> ExpectedValue<T> {
            .init(
                value: value,
                provideValue: { try await self.upgrade() })
        }
        self.subscription = expectedValue(properties.subscription)
        self.postCount = expectedValue(properties.postCount)
        self.commentCount = expectedValue(properties.commentCount)
        self.activeUserCount = expectedValue(properties.activeUserCount)
        self.bannedFromCommunity = expectedValue(properties.bannedFromCommunity)
        self.instance = expectedValue(properties.instance)
        self.moderators = expectedValue(properties.moderators)
        self.discussionLanguageIds = expectedValue(properties.discussionLanguageIds)
        
        updateAuxiliaryModels(with: properties)
        self.shouldBeFavorited = favorited
    }
    
    @MainActor
    public func update(with properties: CommunityProperties) {
        setIfChanged(\.updated, properties.updated)
        setIfChanged(\.displayName, properties.displayName)
        setIfChanged(\.description, properties.description)
        setIfChanged(\.deleted, properties.deleted)
        setIfChanged(\.removed, properties.removed)
        setIfChanged(\.nsfw, properties.nsfw)
        setIfChanged(\.avatar, properties.avatar)
        setIfChanged(\.banner, properties.banner)
        setIfChanged(\.hidden, properties.hidden)
        setIfChanged(\.onlyModeratorsCanPost, properties.onlyModeratorsCanPost)
        
        updateIfChanged(\.subscription.value_, properties.subscription)
        updateIfChanged(\.postCount.value_, properties.postCount)
        updateIfChanged(\.commentCount.value_, properties.commentCount)
        updateIfChanged(\.activeUserCount.value_, properties.activeUserCount)
        updateIfChanged(\.bannedFromCommunity.value_, properties.bannedFromCommunity)
        setIfNil(\.instance.value_, properties.instance)
        updateIfChanged(\.moderators.value_, properties.moderators)
        updateIfChanged(\.discussionLanguageIds.value_, properties.discussionLanguageIds)
        
        updateAuxiliaryModels(with: properties)
        self.shouldBeFavorited = favorited
    }
    
    @MainActor
    public func softUpdate(with properties: CommunityProperties) {
        setIfNil(\.subscription.value_, properties.subscription)
        setIfNil(\.postCount.value_, properties.postCount)
        setIfNil(\.commentCount.value_, properties.commentCount)
        setIfNil(\.activeUserCount.value_, properties.activeUserCount)
        setIfNil(\.bannedFromCommunity.value_, properties.bannedFromCommunity)
        setIfNil(\.instance.value_, properties.instance)
        setIfNil(\.moderators.value_, properties.moderators)
        setIfNil(\.discussionLanguageIds.value_, properties.discussionLanguageIds)
    }
    
    /// Updates external models with relevant information from this Community's properties. Should be called in init and update.
    private func updateAuxiliaryModels(with properties: CommunityProperties) {
        // if subscription status changed, update API
        if properties.subscription != self.subscription.value_ {
            self.api.subscriptions?.updateCommunitySubscription(community: self)
        }
        
        // if favorited but not subscribed, remove from favorites
        if favorited, let subscribed = properties.subscription?.subscribed, !subscribed {
            self.api.subscriptions?.favoriteIDs.remove(id)
        }
        
        // if banned, update ban status
        if let bannedFromCommunity = properties.bannedFromCommunity as? Bool {
            api.myPerson?.updateKnownCommunityBanState(id: id, banned: bannedFromCommunity)
        }
    }
    
    // MARK: Upgrades
    
    public func upgrade() async throws {
        try await updateQueue.upgrade()
    }
    
    public func refresh() async throws {
        try await updateQueue.refresh()
    }
    
    public func fetchUpgraded() async throws -> CommunityProperties {
        let snapshot = try await api.repository.getCommunity(id: id)
        return await .init(api: api, snapshot: .community3(snapshot))
    }
    
    public func resolve(with api: ApiClient) async throws -> Self {
        let stub = CommunityStub(api: api, url: allResolvableUrls[0])
        return try await stub.getCommunity() as! Self
    }
}

// MARK: Computed

public extension Community {
    var favorited: Bool {
        api.subscriptions?.isFavorited(self) ?? false
    }
    
    /// - Note: will trigger fetch if subscription value not present
    var subscriptionTier: SubscriptionTier {
        if favorited { return .favorited }
        if subscription.value?.subscribed ?? false { return .subscribed }
        return .unsubscribed
    }
}

// MARK: Interactions

public extension Community {
    
    // Get Posts
    
    func getPosts(
        sort: PostSortType,
        page: Int = 1,
        cursor: String? = nil,
        limit: Int,
        filter: GetContentFilter? = nil,
        showHidden: Bool = false
    ) async throws -> (posts: [Post], cursor: String?) {
        try await api.getPosts(
            communityId: id,
            sort: sort,
            page: page,
            cursor: cursor,
            limit: limit,
            filter: filter,
            showHidden: showHidden
        )
    }
    
    // Subscribe
    
    var updateSubscribed: ((Bool) -> Void)? {
        if let subscription = subscription.value {
            return { self.updateSubscribed($0, subscription: subscription) }
        }
        return nil
    }
    
    private func updateSubscribed(_ newValue: Bool, subscription: SubscriptionModel) {
        self.subscription.value_ = subscription.withSubscriptionStatus(subscribed: newValue, isLocal: apiIsLocal)
        let oldFavorited = shouldBeFavorited
        if !newValue {
            self.shouldBeFavorited = false
        }
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.subscribeToCommunity(id: self.id, subscribe: newValue)
                    return await .init(api: self.api, snapshot: .community2(snapshot))
                } catch {
                    self.shouldBeFavorited = oldFavorited
                    throw error
                }
            }
        }
    }
    
    // Favorite
    
    var updateFavorite: ((Bool) -> Void)? {
        if let subscription = subscription.value {
            return { self.updateFavorite($0, subscription: subscription) }
        }
        return nil
    }
    
    private func updateFavorite(_ newValue: Bool, subscription: SubscriptionModel) {
        self.shouldBeFavorited = newValue
        if !subscription.subscribed, newValue {
            updateSubscribed(true, subscription: subscription)
        }
    }
    
    // Remove
    
    func updateRemoved(_ newValue: Bool, reason: String?, callback: ((UpdateStatus) -> Void)?) {
        removed = newValue
        removedPending = true
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.removeCommunity(id: self.id, remove: newValue, reason: reason)
                    callback?(.success)
                    return await .init(api: self.api, snapshot: .community2(snapshot))
                } catch {
                    callback?(.failure(error))
                    throw (error)
                }
            }
        }
    }
    
    // Purge
    
    func purge(reason: String?) async throws {
        try await api.purgeCommunity(id: id, reason: reason)
        purged = true
    }
    
    // Edit Moderators
    
    func addModerator(personId: Int, added: Bool) async throws {
        try await api.addModerator(communityId: id, personId: personId, added: added)
    }
    
    func addModerator(_ person: Person, added: Bool) async throws {
        try await api.addModerator(communityId: id, personId: person.id, added: added)
    }
    
    // Description

    func updateDescription(_ newValue: String?, callback: ((UpdateStatus) -> Void)?) {
        description = newValue
        
        Task {
            await updateQueue.addItem {
                do {
                    let ret: CommunityProperties = try await .init(
                        api: self.api,
                        snapshot: .community2(self.api.repository.editCommunityDescription(id: self.id, newValue: newValue)))
                    callback?(.success)
                    return ret
                } catch {
                    callback?(.failure(error))
                    throw(error)
                }
            }
        }
    }
}

// MARK: Shim

public extension Community {
    var displayName_: String { displayName }
    var description_: String? { description }
    var banner_: URL? { banner }
    var created_: Date { created }
    var updated_: Date? { updated }
    
    internal func takeSnapshot1() -> Community1Snapshot {
        .init(actorId: actorId,
              id: id,
              name: name,
              created: created,
              instanceId: instanceId,
              updated: updated,
              displayName: displayName,
              description: description,
              deleted: deleted,
              removed: removed,
              nsfw: nsfw,
              avatar: avatar,
              banner: banner,
              hidden: hidden,
              onlyModeratorsCanPost: onlyModeratorsCanPost,
              allPropertiesPresent: false
        )
    }
}

