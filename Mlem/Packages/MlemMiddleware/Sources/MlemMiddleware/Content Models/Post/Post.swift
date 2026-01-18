//
//  Post.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-12-18.
//

import Observation
import Foundation
import Nuke
import Rest

public struct PostEmbed: Equatable {
    public let title: String?
    public let description: String?
    public let videoUrl: URL?
}

@Observable
public class Post:
    UnifiedModelProviding,
    FeedLoadable,
    SelectableContentProviding,
    ContentIdentifiable,
    Resolvable,
    Sharable,
    UnifiedReadableProviding,
    Interactable1Providing,
    PersonContentProviding,
    DeletableProviding,
    ReportableProviding,
    RemovableProviding,
    PurgableProviding {
    public typealias Properties = PostProperties
    
    public init(
        api: ApiClient,
        properties: PostProperties
    ) {
        self.api = api
        self.properties = properties
        
        func expectedValue<T>(_ value: T?) -> ExpectedValue<T> {
            .init(
                value: value,
                provideValue: { try await self.upgrade() })
        }
        
        func dummyExpectedValue<T>(_ value: T?) -> ExpectedValue<T> {
            .init(
                value: value,
                provideValue: { assertionFailure("This should be overridden") })
        }
        
        self.actorId = properties.actorId
        self.id = properties.id
        self.creatorId = properties.creatorId
        self.communityId = properties.communityId
        self.created = properties.created
        self.title = properties.title
        self.content = properties.content
        self.linkUrl = properties.linkUrl
        self.embed = properties.embed
        self.nsfw = properties.nsfw
        self.thumbnailUrl = properties.thumbnailUrl
        self.updated = properties.updated
        self.languageId = properties.languageId
        self.altText = properties.altText
        self.deleted = properties.deleted
        self.removed = properties.removed
        self.pinnedCommunity = properties.pinnedCommunity
        self.pinnedInstance = properties.pinnedInstance
        self.locked = properties.locked
        self.creator = dummyExpectedValue(properties.creator)
        self.community = dummyExpectedValue(properties.community)
        self.commentCount = dummyExpectedValue(properties.commentCount)
        self.unreadCommentCount = dummyExpectedValue(properties.unreadCommentCount)
        self.creatorIsModerator = dummyExpectedValue(properties.creatorIsModerator)
        self.creatorIsAdmin = dummyExpectedValue(properties.creatorIsAdmin)
        self.creatorBannedFromCommunity = dummyExpectedValue(properties.creatorBannedFromCommunity)
        self.creatorBlocked = dummyExpectedValue(properties.creatorBlocked)
        self.votes = dummyExpectedValue(properties.votes)
        self.saved = dummyExpectedValue(properties.saved)
        self.read = dummyExpectedValue(properties.read)
        self.hidden = dummyExpectedValue(properties.hidden)
        self.crossPosts = dummyExpectedValue(properties.crossPosts)
        
        self.creator = expectedValue(properties.creator)
        self.community = expectedValue(properties.community)
        self.commentCount = expectedValue(properties.commentCount)
        self.unreadCommentCount = expectedValue(properties.unreadCommentCount)
        self.creatorIsModerator = expectedValue(properties.creatorIsModerator)
        self.creatorIsAdmin = expectedValue(properties.creatorIsAdmin)
        self.creatorBannedFromCommunity = expectedValue(properties.creatorBannedFromCommunity)
        self.creatorBlocked = expectedValue(properties.creatorBlocked)
        self.votes = expectedValue(properties.votes)
        self.saved = expectedValue(properties.saved)
        self.read = expectedValue(properties.read)
        self.hidden = expectedValue(properties.hidden)
        self.crossPosts = expectedValue(properties.crossPosts)
    }
    
    /// Updates this properties with the values from the given PostProperties, preferring the incoming values
    @MainActor
    public func update(with properties: PostProperties) {
//        actorId = properties.actorId
//        id = properties.id
//        creatorId = properties.creatorId
//        communityId = properties.communityId
//        created = properties.created
//        title = properties.title
//        content = properties.content
//        linkUrl = properties.linkUrl
//        embed = properties.embed
//        nsfw = properties.nsfw
//        thumbnailUrl = properties.thumbnailUrl
//        updated = properties.updated
//        languageId = properties.languageId
//        altText = properties.altText
//        deleted = properties.deleted
//        removed = properties.removed
//        pinnedCommunity = properties.pinnedCommunity
//        pinnedInstance = properties.pinnedInstance
//        locked = properties.locked

//        creator.value_ = properties.creator ?? creator.value_
//        community.value_ = properties.community ?? community.value_
//        commentCount.value_ = properties.commentCount ?? commentCount.value_
//        unreadCommentCount.value_ = properties.unreadCommentCount ?? unreadCommentCount.value_
//        creatorIsModerator.value_ = properties.creatorIsModerator ?? creatorIsModerator.value_
//        creatorIsAdmin.value_ = properties.creatorIsAdmin ?? creatorIsAdmin.value_
//        creatorBannedFromCommunity.value_ = properties.creatorBannedFromCommunity ?? creatorBannedFromCommunity.value_
//        creatorBlocked.value_ = properties.creatorBlocked ?? creatorBlocked.value_
        votes.value_ = properties.votes ?? votes.value_
//        saved.value_ = properties.saved ?? saved.value_
//        read.value_ = properties.read ?? read.value_
//        hidden.value_ = properties.hidden ?? hidden.value_
//        
//        crossPosts.value_ = properties.crossPosts ?? crossPosts.value_
        
        if let creator = creator.value_, let creatorBannedFromCommunity = creatorBannedFromCommunity.value_ {
            creator.person1.updateKnownCommunityBanState(id: communityId, banned: creatorBannedFromCommunity)
        }
    }
    
    // MARK: Core
    
    @ObservationIgnored
    lazy var updateQueue: UnifiedUpdateQueue<Post> = .init(parent: self)
    
    public var api: ApiClient
    
    @ObservationIgnored
    public var properties: PostProperties
//    public var properties: PostProperties {
//        didSet {
//            pinnedCommunityPending = false
//            pinnedInstancePending = false
//            lockedPending = false
//            nsfwPending = false
//            removedPending = false
//        }
//    }
    
    public func upgrade() async throws {
        try await updateQueue.upgrade()
    }
    
    public func fetchUpgraded() async throws -> PostProperties {
        let snapshot = try await api.repository.getPost(id: id)
        let creator = await api.caches.person1.getModel(api: api, from: snapshot.post.creator)
        let community = await api.caches.community1.getModel(api: api, from: snapshot.post.community)
        let crossPosts = await api.caches.post.getModels(api: api, from: snapshot.crossPosts.map { .post2($0) })
        
        return .init(snapshot: .post3(snapshot), creator: creator, community: community, crossPosts: crossPosts)
    }
    
    // MARK: Custom Properties
    // Mlem-specific properties that are not reflected in the API
    
    public var readQueued: Bool = false
    public var pinnedCommunityPending: Bool = false
    public var pinnedInstancePending: Bool = false
    public var lockedPending: Bool = false
    public var nsfwPending: Bool = false
    public var removedPending: Bool = false
    public var purged: Bool = false
    public var embeddedMediaUrl: URL?
    
    // MARK: API Properties
    // Properties that are provided directly by the API
    
//    private func expectedValue<T>(_ keyPath: WritableKeyPath<Post, T?>) -> ExpectedValue<T> {
//        .init(
//            value: self[keyPath: keyPath],
//            provideValue: { try await self.upgrade() })
//    }
    
    public var actorId: ActorIdentifier
    
    public var id: Int
    
    public var creatorId: Int
    
    public var communityId: Int
    
    public var created: Date
    
    public var title: String
    
    public var content: String?
    
    public var linkUrl: URL?
    
    public var embed: PostEmbed?
    
    public var nsfw: Bool
    
    public var thumbnailUrl: URL?
    
    public var updated: Date?
    
    public var languageId: Int
    
    public var altText: String?
    
    public var deleted: Bool
    
    public var removed: Bool
    
    public var pinnedCommunity: Bool
    
    public var pinnedInstance: Bool
    
    public var locked: Bool

    public var creator: ExpectedValue<any Person>
    
    public var community: ExpectedValue<any Community>
    
    public var commentCount: ExpectedValue<Int>

    public var unreadCommentCount: ExpectedValue<Int>

    public var creatorIsModerator: ExpectedValue<Bool>

    public var creatorIsAdmin: ExpectedValue<Bool>

    public var creatorBannedFromCommunity: ExpectedValue<Bool>

    public var creatorBlocked: ExpectedValue<Bool>

    public var votes: ExpectedValue<VotesModel>

    public var saved: ExpectedValue<Bool>

    public var read: ExpectedValue<Bool>
//    = .init(
//        getValue: { if let value = self.properties.read { self.readQueued || value } else { nil }},
//        provideValue: { try await self.upgrade() }
//    )

    public var hidden: ExpectedValue<Bool>
    
    public var crossPosts: ExpectedValue<[Post]>
}

// MARK: - Computed

public extension Post {
    var linkHost: String? {
        if case let .link(link) = type {
            return link.host
        }
        return nil
    }
    
    var isOwnPost: Bool { creatorId == api.myPerson?.id }
}

// MARK: - Interactions

public extension Post {

    func updateSaved(_ newValue: Bool) {
        saved.value_ = newValue
        read.value_ = true
        
        Task {
            await updateQueue.addItem {
                .init(snapshot: .post2(try await self.api.repository.savePost(id: self.id, save: newValue)))
            }
        }
    }
    
    // Vote
    
    var updateVote: ((ScoringOperation) -> Void)? {
        if let votes = votes.value {
            return { self.updateVote($0, votes: votes) }
        }
        return nil
    }
    
    private func updateVote(_ newValue: ScoringOperation, votes: VotesModel) {
        self.votes.value_ = votes.applyScoringOperation(operation: newValue)
        read.value_ = true
        
        Task {
            await updateQueue.addItem {
                .init(snapshot: .post2(try await self.api.repository.voteOnPost(id: self.id, score: newValue)))
            }
        }
    }
    
    // Reply
    
    func reply(content: String, languageId: Int?) async throws -> Comment2 {
        try await self.api.replyToPost(id: id, content: content, languageId: languageId)
    }
    
    // Hide
    
    func updateHidden(_ newValue: Bool) {
        hidden.value_ = newValue
        read.value_ = true
        
        Task {
            await updateQueue.addItem { properties in
                try await self.api.repository.hidePost(id: self.id, hide: newValue)
                var properties = properties
                properties.hidden = newValue
                return properties
            }
        }
    }
    
    // Read
    
    func updateRead(_ newValue: Bool, shouldQueue: Bool = false) {
        if shouldQueue {
            readQueued = newValue
            Task {
                if newValue {
                    await api.markReadQueue.add(id)
                } else {
                    await api.markReadQueue.remove(id)
                }
            }
        } else {
            read.value_ = newValue
            Task {
                await updateQueue.addItem { properties in
                    try await self.api.repository.markPostAsRead(id: self.id, read: newValue)
                    var properties = properties
                    properties.read = newValue
                    return properties
                }
            }
        }
    }
    
    /// Update the post when its queued mark read operation completes.
    func queuedMarkReadCompleted() {
        // sending this through the updateQueue ensures queue.lastVerifiedSnapshot receives the correct read value
        Task {
            await updateQueue.addItem { properties in
                var properties = properties
                properties.read = true
                return properties
            }
            readQueued = false
        }
    }
    
    // Pin
    
    /// Pins or unpins this post to the community according to newValue
    /// - Parameters:
    ///   - newValue: true to pin post, false to unpin
    ///   - callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func updatePinnedCommunity(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        pinnedCommunity = newValue
        pinnedCommunityPending = true
        
        Task {
            await updateQueue.addItem {
                do {
                    let ret = try await self.api.repository.pinPost(id: self.id, pin: newValue, to: .community)
                    callback?(.success)
                    return .init(snapshot: .post2(ret))
                } catch {
                    callback?(.failure(error))
                    throw error
                }
            }
        }
    }
    
    /// Pins or unpins this post to the instance according to newValue
    /// - Parameters:
    ///   - newValue: true to pin post, false to unpin
    ///   - callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func updatePinnedInstance(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        pinnedInstance = newValue
        pinnedInstancePending = true
        
        Task {
            await updateQueue.addItem {
                do {
                    let ret = try await self.api.repository.pinPost(id: self.id, pin: newValue, to: .instance)
                    callback?(.success)
                    return .init(snapshot: .post2(ret))
                } catch {
                    callback?(.failure(error))
                    throw error
                }
            }
        }
    }
       
    
    // Lock
    
    /// Locks or unlocks this post according to newValue
    /// - Parameters:
    ///   - newValue: true to lock post, false to unlock
    ///   - callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func updateLocked(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        locked = newValue
        lockedPending = true
        Task {
            await updateQueue.addItem {
                do {
                    let ret = try await self.api.repository.lockPost(id: self.id, lock: newValue)
                    callback?(.success)
                    return .init(snapshot: .post2(ret))
                } catch {
                    callback?(.failure(error))
                    throw (error)
                }
            }
        }
    }
    
    // Get Comments
    
    func getComments(
        sort: CommentSortType = .hot,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2] {
        try await api.getComments(
            postId: id,
            sort: sort,
            page: page,
            maxDepth: maxDepth,
            limit: limit,
            filter: filter
        )
    }
    
    // Edit
    
    func edit(
        title: String,
        content: String?,
        linkUrl: URL?,
        altText: String?,
        thumbnail: URL?,
        nsfw: Bool,
        languageId: Int?
    ) throws {
        self.title = title
        self.content = content
        self.linkUrl = linkUrl
        self.altText = altText
        self.thumbnailUrl = thumbnail
        self.nsfw = nsfw
        self.languageId = languageId ?? self.languageId
        
        Task {
            await updateQueue.addItem {
                .init(snapshot: .post2(try await self.api.repository.editPost(
                    id: self.id,
                    title: title,
                    content: content,
                    linkUrl: linkUrl,
                    altText: altText,
                    thumbnail: thumbnail,
                    nsfw: nsfw,
                    languageId: languageId
                )))
            }
        }
    }
    
    // Get Votes
    
    func getVotes(page: Int, limit: Int) async throws -> [PersonVote] {
        try await api.getPostVotes(id: id, communityId: communityId, page: page, limit: limit)
    }
    
    // Deleted
    
    func updateDeleted(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        deleted = newValue
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.deletePost(id: self.id, delete: newValue)
                    callback?(.success)
                    return .init(snapshot: .post2(snapshot))
                } catch {
                    callback?(.failure(error))
                    throw error
                }
            }
        }
    }
    
    // NSFW
    
    func updateNsfw(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        nsfw = newValue
        nsfwPending = true
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.setPostNsfw(id: self.id, nsfw: newValue)
                    callback?(.success)
                    return .init(snapshot: .post1(snapshot))
                } catch {
                    callback?(.failure(error))
                    throw (error)
                }
            }
        }
    }
    
    // Remove
    
    func updateRemoved(_ newValue: Bool, reason: String?, callback: ((UpdateStatus) -> Void)?) {
        removed = newValue
        removedPending = true
        
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.removePost(id: self.id, remove: newValue, reason: reason)
                    callback?(.success)
                    return .init(snapshot: .post2(snapshot))
                } catch {
                    callback?(.failure(error))
                    throw (error)
                }
            }
        }
    }
    
    // Purge
    
    func purge(reason: String?) async throws {
        try await api.purgePost(id: id, reason: reason)
    }
}
