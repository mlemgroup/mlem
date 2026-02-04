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
    InteractableProviding,
    PersonContentProviding,
    DeletableProviding,
    ReportableProviding,
    RemovableProviding,
    PurgableProviding {    
    public typealias Properties = PostProperties
    
    public var api: ApiClient
    private let properties: PostProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<Post> = .init(parent: self, properties: properties)
    
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
    // Properties that are provided by the API

    public let actorId: ActorIdentifier
    public let id: Int
    public let creatorId: Int
    public let communityId: Int
    public let created: Date
    public var title: String
    public var content: String?
    public var linkUrl: URL?
    public var embed: PostEmbed?
    public var poll: PostPoll?
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
    
    public var creator: ExpectedValue<any DeprecatedPerson>
    public var community: ExpectedValue<any Community>
    public var commentCount: ExpectedValue<Int>
    public var unreadCommentCount: ExpectedValue<Int>
    public var creatorIsModerator: ExpectedValue<Bool>
    public var creatorIsAdmin: ExpectedValue<Bool>
    public var creatorBannedFromCommunity: ExpectedValue<Bool>
    public var creatorBlocked: ExpectedValue<Bool>
    public var votes: ExpectedValue<VotesModel>
    public var saved: ExpectedValue<Bool>
    public var readStatus: ExpectedValue<Bool>
    public var read: ExpectedValue<Bool> {
        .init(
            value: readStatus.value?.or(readQueued),
            provideValue: { try await self.upgrade() })
    }
    public var hidden: ExpectedValue<Bool>
    public var crossPosts: ExpectedValue<[Post]>
    
    // MARK: Initializers and Updates
    
    public init(api: ApiClient, properties: PostProperties) {
        self.api = api
        self.properties = properties
        
        self.actorId = properties.actorId
        self.id = properties.id
        self.creatorId = properties.creatorId
        self.communityId = properties.communityId
        self.created = properties.created
        self.title = properties.title
        self.content = properties.content
        self.linkUrl = properties.linkUrl
        self.embed = properties.embed
        self.poll = properties.poll
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
        
        // because upgrade() is not available until all properties are initialized, first populate all properties
        // with ExpectedValues that don't actually do anything, then reassign them properly at the end of the init
        // this is somewhat cumbersome but avoids lazy vars, which are very awkward in Observables
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
        self.readStatus = dummyExpectedValue(properties.read)
        self.hidden = dummyExpectedValue(properties.hidden)
        self.crossPosts = dummyExpectedValue(properties.crossPosts)
        
        func expectedValue<T>(_ value: T?) -> ExpectedValue<T> {
            .init(
                value: value,
                provideValue: { try await self.upgrade() })
        }
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
        self.readStatus = expectedValue(properties.read)
        self.hidden = expectedValue(properties.hidden)
        self.crossPosts = expectedValue(properties.crossPosts)
    }
    
    @MainActor
    public func update(with properties: PostProperties) {
        setIfChanged(\.title, properties.title)
        setIfChanged(\.content, properties.content)
        setIfChanged(\.linkUrl, properties.linkUrl)
        setIfChanged(\.embed, properties.embed)
        setIfChanged(\.poll, properties.poll)
        setIfChanged(\.nsfw, properties.nsfw)
        setIfChanged(\.thumbnailUrl, properties.thumbnailUrl)
        setIfChanged(\.updated, properties.updated)
        setIfChanged(\.languageId, properties.languageId)
        setIfChanged(\.altText, properties.altText)
        setIfChanged(\.deleted, properties.deleted)
        setIfChanged(\.removed, properties.removed)
        setIfChanged(\.pinnedCommunity, properties.pinnedCommunity)
        setIfChanged(\.pinnedInstance, properties.pinnedInstance)
        setIfChanged(\.locked, properties.locked)

        // creator and community are not expected to change value, but need to be assigned if absent
        setIfNil(\.creator.value_, properties.creator ?? creator.value_)
        setIfNil(\.community.value_, properties.community ?? community.value_)
        setIfChanged(\.commentCount.value_, properties.commentCount ?? commentCount.value_)
        setIfChanged(\.unreadCommentCount.value_, properties.unreadCommentCount ?? unreadCommentCount.value_)
        setIfChanged(\.creatorIsModerator.value_, properties.creatorIsModerator ?? creatorIsModerator.value_)
        setIfChanged(\.creatorIsAdmin.value_, properties.creatorIsAdmin ?? creatorIsAdmin.value_)
        setIfChanged(\.creatorBannedFromCommunity.value_ , properties.creatorBannedFromCommunity ?? creatorBannedFromCommunity.value_)
        setIfChanged(\.creatorBlocked.value_, properties.creatorBlocked ?? creatorBlocked.value_)
        setIfChanged(\.votes.value_, properties.votes ?? votes.value_)
        setIfChanged(\.saved.value_, properties.saved ?? saved.value_)
        setIfChanged(\.readStatus.value_, properties.read ?? readStatus.value_)
        setIfChanged(\.hidden.value_, properties.hidden ?? hidden.value_)

        setIfChanged(\.crossPosts.value_, properties.crossPosts ?? crossPosts.value_)
    }
    
    @MainActor
    public func softUpdate(with properties: PostProperties) {
        setIfNil(\.creator.value_, properties.creator)
        setIfNil(\.community.value_, properties.community)
        setIfNil(\.commentCount.value_, properties.commentCount)
        setIfNil(\.unreadCommentCount.value_, properties.unreadCommentCount)
        setIfNil(\.creatorIsModerator.value_, properties.creatorIsModerator)
        setIfNil(\.creatorIsAdmin.value_, properties.creatorIsAdmin)
        setIfNil(\.creatorBannedFromCommunity.value_ , properties.creatorBannedFromCommunity)
        setIfNil(\.creatorBlocked.value_, properties.creatorBlocked)
        setIfNil(\.votes.value_, properties.votes)
        setIfNil(\.saved.value_, properties.saved)
        setIfNil(\.readStatus.value_, properties.read)
        setIfNil(\.hidden.value_, properties.hidden)

        setIfNil(\.crossPosts.value_, properties.crossPosts ?? crossPosts.value_)
    }
    
    // MARK: Upgrades
    
    public func upgrade() async throws {
        try await updateQueue.upgrade()
    }
    
    public func refresh() async throws {
        try await updateQueue.refresh()
    }
    
    public func fetchUpgraded() async throws -> PostProperties {
        let snapshot = try await api.repository.getPost(id: id)
        return await .init(api: api, snapshot: .post3(snapshot))
    }
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
    
    // Vote
    
    var updateVote: ((ScoringOperation) -> Void)? {
        if let votes = votes.value {
            return { self.updateVote($0, votes: votes) }
        }
        return nil
    }
    
    private func updateVote(_ newValue: ScoringOperation, votes: VotesModel) {
        self.votes.value_ = votes.applyScoringOperation(operation: newValue)
        readStatus.value_ = true
        
        Task {
            await updateQueue.addItem {
                await .init(api: self.api, snapshot: .post2(try await self.api.repository.voteOnPost(id: self.id, score: newValue)))
            }
        }
    }
    
    // Save
    
    func updateSaved(_ newValue: Bool) {
        saved.value_ = newValue
        readStatus.value_ = true
        
        Task {
            await updateQueue.addItem {
                await .init(api: self.api, snapshot: .post2(try await self.api.repository.savePost(id: self.id, save: newValue)))
            }
        }
    }
    
    // Reply
    
    func reply(content: String, languageId: Int?) async throws -> Comment {
        try await self.api.replyToPost(id: id, content: content, languageId: languageId)
    }
    
    // Hide
    
    func updateHidden(_ newValue: Bool) {
        hidden.value_ = newValue
        readStatus.value_ = true
        
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
            readStatus.value_ = newValue
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
                    return await .init(api: self.api, snapshot: .post2(ret))
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
                    return await .init(api: self.api, snapshot: .post2(ret))
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
                    return await .init(api: self.api, snapshot: .post2(ret))
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
    ) async throws -> [Comment] {
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
                await .init(api: self.api, snapshot: .post2(try await self.api.repository.editPost(
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
                    return await .init(api: self.api, snapshot: .post2(snapshot))
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
                    return await .init(api: self.api, snapshot: .post1(snapshot))
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
                    return await .init(api: self.api, snapshot: .post2(snapshot))
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
