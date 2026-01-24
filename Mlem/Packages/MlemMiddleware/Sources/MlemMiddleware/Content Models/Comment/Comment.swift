//
//  Comment.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-19.
//

import Observation
import Foundation

@Observable
public class Comment:
    UnifiedModelProviding,
    FeedLoadable,
    SelectableContentProviding,
    ContentIdentifiable,
    OwnershipProviding,
    Interactable1Providing,
    CommentResolvable,
    Sharable {
    public typealias Properties = CommentProperties
    
    public var api: ApiClient
    private let properties: CommentProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<Comment> = .init(parent: self, properties: properties)
    
    // MARK: Custom Properties
    // Mlem-specific properties that are not reflected in the API
    
    public var removedPending: Bool = false
    public var purged: Bool = false
    
    // MARK: API Properties
    // Properties that are provided by the API
    public let actorId: ActorIdentifier
    public let id: Int
    public let creatorId: Int
    public let postId: Int
    public let parentCommentIds: [Int]
    public let created: Date
    public var content: String
    public var updated: Date?
    public var distinguished: Bool
    public var languageId: Int
    public var deleted: Bool
    public var removed: Bool
    
    // from Comment2Snapshot
    public var creator: ExpectedValue<(any Person)>
    public var post: ExpectedValue<Post>
    public var community: ExpectedValue<(any Community)>
    public var commentCount: ExpectedValue<Int>
    public var creatorIsModerator: ExpectedValue<Bool>
    public var creatorIsAdmin: ExpectedValue<Bool>
    public var creatorBannedFromCommunity: ExpectedValue<Bool>
    public var votes: ExpectedValue<VotesModel>
    public var saved: ExpectedValue<Bool>
    
    public init(api: ApiClient, properties: CommentProperties) {
        self.api = api
        self.properties = properties
        
        self.actorId = properties.actorId
        self.id = properties.id
        self.creatorId = properties.creatorId
        self.postId = properties.postId
        self.parentCommentIds = properties.parentCommentIds
        self.created = properties.created
        self.content = properties.content
        self.updated = properties.updated
        self.distinguished = properties.distinguished
        self.languageId = properties.languageId
        self.deleted = properties.deleted
        self.removed = properties.removed
        
        // because upgrade() is not available until all properties are initialized, first populate all properties
        // with ExpectedValues that don't actually do anything, then reassign them properly at the end of the init
        // this is somewhat cumbersome but avoids lazy vars, which are very awkward in Observables
        func dummyExpectedValue<T>(_ value: T?) -> ExpectedValue<T> {
            .init(
                value: value,
                provideValue: { assertionFailure("This should be overridden") })
        }
        self.creator = dummyExpectedValue(properties.creator)
        self.post = dummyExpectedValue(properties.post)
        self.community = dummyExpectedValue(properties.community)
        self.commentCount = dummyExpectedValue(properties.commentCount)
        self.creatorIsModerator = dummyExpectedValue(properties.creatorIsModerator)
        self.creatorIsAdmin = dummyExpectedValue(properties.creatorIsAdmin)
        self.creatorBannedFromCommunity = dummyExpectedValue(properties.creatorBannedFromCommunity)
        self.votes = dummyExpectedValue(properties.votes)
        self.saved = dummyExpectedValue(properties.saved)
        
        func expectedValue<T>(_ value: T?) -> ExpectedValue<T> {
            .init(
                value: value,
                provideValue: { try await self.upgrade() })
        }
        self.creator = expectedValue(properties.creator)
        self.post = expectedValue(properties.post)
        self.community = expectedValue(properties.community)
        self.commentCount = expectedValue(properties.commentCount)
        self.creatorIsModerator = expectedValue(properties.creatorIsModerator)
        self.creatorIsAdmin = expectedValue(properties.creatorIsAdmin)
        self.creatorBannedFromCommunity = expectedValue(properties.creatorBannedFromCommunity)
        self.votes = expectedValue(properties.votes)
        self.saved = expectedValue(properties.saved)
    }
    
    public func update(with properties: CommentProperties) {
        setIfChanged(\.content, properties.content)
        setIfChanged(\.updated, properties.updated)
        setIfChanged(\.distinguished, properties.distinguished)
        setIfChanged(\.languageId, properties.languageId)
        setIfChanged(\.deleted, properties.deleted)
        setIfChanged(\.removed, properties.removed)
        
        setIfNil(\.creator.value_, properties.creator)
        setIfNil(\.post.value_, properties.post)
        setIfNil(\.community.value_, properties.community)
        setIfChanged(\.commentCount.value_, properties.commentCount)
        setIfChanged(\.creatorIsModerator.value_, properties.creatorIsModerator)
        setIfChanged(\.creatorIsAdmin.value_, properties.creatorIsAdmin)
        setIfChanged(\.creatorBannedFromCommunity.value_, properties.creatorBannedFromCommunity)
        setIfChanged(\.votes.value_, properties.votes)
        setIfChanged(\.saved.value_, properties.saved)
    }
    
    public func softUpdate(with properties: CommentProperties) {
        setIfNil(\.creator.value_, properties.creator)
        setIfNil(\.post.value_, properties.post)
        setIfNil(\.community.value_, properties.community)
        setIfNil(\.commentCount.value_, properties.commentCount)
        setIfNil(\.creatorIsModerator.value_, properties.creatorIsModerator)
        setIfNil(\.creatorIsAdmin.value_, properties.creatorIsAdmin)
        setIfNil(\.creatorBannedFromCommunity.value_, properties.creatorBannedFromCommunity)
        setIfNil(\.votes.value_, properties.votes)
        setIfNil(\.saved.value_, properties.saved)
    }
    
    public func upgrade() async throws {
        try await updateQueue.upgrade()
    }
    
    public func fetchUpgraded() async throws -> CommentProperties {
        let snapshot = try await api.repository.getComment(id: id)
        return await .init(api: api, snapshot: .comment2(snapshot))
    }
}

// MARK: - Computed

public extension Comment {
    var depth: Int { parentCommentIds.count }
    
    var parentCommentId: Int? { parentCommentIds.last }
}

// MARK: - Interactions

public extension Comment {
    
    func updateRemoved(_ newValue: Bool, reason: String?, callback: ((UpdateStatus) -> Void)?) {
        removed = newValue
        removedPending = true
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.removeComment(id: self.id, remove: newValue, reason: reason)
                    callback?(.success)
                    return await .init(api: self.api, snapshot: .comment2(snapshot))
                } catch {
                    callback?(.failure(error))
                    throw (error)
                }
            }
        }
    }
    
    func reply(content: String, languageId: Int? = nil) async throws -> Comment {
        try await api.replyToComment(postId: postId, parentId: id, content: content, languageId: languageId)
    }
    
    func purge(reason: String?) async throws {
        try await api.purgeComment(id: id, reason: reason)
    }
    
    func updateDeleted(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        deleted = newValue
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.deleteComment(id: self.id, delete: newValue)
                    callback?(.success)
                    return await .init(api: self.api, snapshot: .comment2(snapshot))
                } catch {
                    callback?(.failure(error))
                    throw (error)
                }
            }
        }
    }
    
    func edit(content: String, languageId: Int?) async throws {
        self.content = content
        if let languageId {
            self.languageId = languageId
        }
        Task {
            await updateQueue.addItem {
                try await .init(
                    api: self.api,
                    snapshot: .comment2(self.api.repository.editComment(id: self.id, content: content, languageId: languageId)))
            }
        }
    }
    
    /// Get the parent comment, or return `nil` if there is no parent
    func getParent(cachedValueAcceptable: Bool = false) async throws -> Comment? {
        if let parentId = parentCommentIds.last {
            if cachedValueAcceptable, let comment = api.caches.comment.retrieveModel(cacheId: parentId) { return comment }
            return try await api.getComment(id: parentId)
        }
        return nil
    }
    
    func getParents() async throws -> [Comment] {
        guard let first = parentCommentIds.first else { return [] }
        let comments = try await api.getComments(
            parentId: first,
            sort: .new,
            page: 1,
            maxDepth: parentCommentIds.count,
            limit: 1000
        )
        var i = 0
        return comments.filter { comment in
            if comment.id == parentCommentIds[i] {
                i += 1
                return true
            }
            return false
        }
    }
    
    func getChildren(
        sort: CommentSortType = .hot,
        includedParentCount: Int = 0,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment] {
        let parentId: Int
        if includedParentCount <= 0 {
            parentId = id
        } else {
            parentId = parentCommentIds.dropLast(includedParentCount - 1).last ?? parentCommentIds.first ?? id
        }
        let comments = try await api.getComments(
            parentId: parentId,
            sort: sort,
            page: page,
            maxDepth: maxDepth,
            limit: limit,
            filter: filter
        )
        if includedParentCount <= 0 {
            return comments
        }
        
        return comments.filter { $0.parentCommentIds.contains(id) || self.parentCommentIds.contains($0.id) || $0.id == self.id }
    }
    
    func getVotes(page: Int, limit: Int, communityId: Int) async throws -> [PersonVote] {
        try await api.getCommentVotes(id: id, communityId: communityId, page: page, limit: limit)
    }
}

// MARK: Shim

public extension Comment {
    func takeSnapshot2() -> Comment2Snapshot? {
        guard let creator = creator.value_,
              let post = post.value_,
              let community = community.value_,
              let commentCount = commentCount.value_,
              let creatorIsModerator = creatorIsModerator.value_,
              let creatorIsAdmin = creatorIsAdmin.value_,
              let creatorBannedFromCommunity = creatorBannedFromCommunity.value_,
              let votes = votes.value_,
              let saved = saved.value_ else {
            assertionFailure("takeSnapshot2() called without high-tier fields available")
            return nil
        }
        
        return .init(comment:
                .init(actorId: actorId,
                      id: id,
                      creatorId: creatorId,
                      postId: postId,
                      parentCommentIds: parentCommentIds,
                      created: created,
                      content: content,
                      updated: updated,
                      distinguished: distinguished,
                      languageId: languageId,
                      deleted: deleted,
                      removed: removed),
                     creator: creator.takeSnapshot1(),
                     post: .init(
                        actorId: post.actorId,
                        id: post.id,
                        creatorId: post.creatorId,
                        communityId: post.communityId,
                        created: post.created,
                        title: post.title,
                        content: post.content,
                        linkUrl: post.linkUrl,
                        embed: post.embed,
                        nsfw: post.nsfw,
                        thumbnailUrl: post.thumbnailUrl,
                        updated: post.updated,
                        languageId: post.languageId,
                        altText: post.altText,
                        deleted: post.deleted,
                        removed: post.removed,
                        pinnedCommunity: post.pinnedCommunity,
                        pinnedInstance: post.pinnedInstance,
                        locked: post.locked),
                     community: community.takeSnapshot1(),
                     commentCount: commentCount,
                     creatorIsModerator: creatorIsModerator,
                     creatorIsAdmin: creatorIsAdmin,
                     creatorBannedFromCommunity: creatorBannedFromCommunity,
                     votes: votes,
                     saved: saved)
    }
}
