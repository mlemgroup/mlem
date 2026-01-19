//
//  Comment1Providing.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation
import Observation

public protocol Comment1Providing:
    CommentStubProviding,
    ActorIdentifiable,
    ContentIdentifiable,
    Interactable1Providing,
    DeletableProviding,
    PurgableProviding,
    SelectableContentProviding,
    Sharable,
    FeedLoadable where FilterType == CommentFilterType {
    var comment1: Comment1 { get }
    var content: String { get }
    var created: Date { get }
    var updated: Date? { get }
    var deleted: Bool { get }
    var creatorId: Int { get }
    var postId: Int { get }
    var parentCommentIds: [Int] { get }
    var distinguished: Bool { get }
    var languageId: Int { get }
    
    func snapshotUpdate(with snapshot: any CommentSnapshotProviding) async
    func takeSnapshot() -> any CommentSnapshotProviding
    var updateQueue: CommentUpdateQueue { get }
}

public typealias DeprecatedComment = Comment1Providing

public extension Comment1Providing {
    static var modelTypeId: ContentType { .comment }
    
    var updateQueue: CommentUpdateQueue { comment1.updateQueue }
    
    var actorId: ActorIdentifier { comment1.actorId }
    var id: Int { comment1.id }
    var content: String { comment1.content }
    var created: Date { comment1.created }
    var updated: Date? { comment1.updated }
    var deleted: Bool { comment1.deleted }
    var creatorId: Int { comment1.creatorId }
    var postId: Int { comment1.postId }
    var parentCommentIds: [Int] { comment1.parentCommentIds }
    var distinguished: Bool { comment1.distinguished }
    var removed: Bool { comment1.removed }
    var removedPending: Bool { comment1.removedPending }
    var languageId: Int { comment1.languageId }
    var purged: Bool { comment1.purged }
    
    var actorId_: ActorIdentifier? { comment1.actorId }
    var content_: String? { comment1.content }
    var created_: Date? { comment1.created }
    var updated_: Date? { comment1.updated }
    var deleted_: Bool? { comment1.deleted }
    var creatorId_: Int? { comment1.creatorId }
    var postId_: Int? { comment1.postId }
    var parentCommentIds_: [Int]? { comment1.parentCommentIds }
    var distinguished_: Bool? { comment1.distinguished }
    var removed_: Bool? { comment1.distinguished }
    var languageId_: Int? { comment1.languageId }
}

// Resolvable conformance
public extension Comment1Providing {
    @inlinable
    var allResolvableUrls: [URL] {
        ContentModelUrlType.allCases.map { resolvableUrl(from: $0) }
    }
}

// Sharable conformance
public extension Comment1Providing {
    func url() -> URL { api.baseUrl.appending(path: "comment/\(id)") }
}

// SelectableContentProviding conformance
public extension Comment1Providing {
    var selectableContent: String? { content }
}

// FeedLoadable conformance
public extension Comment1Providing {
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            return .new(created)
        }
    }
}

// ReportableProviding conformance
public extension Comment1Providing {
    func isOwnContent(myPersonId: Int) -> Bool {
        creatorId == myPersonId
    }
}

public extension Comment1Providing {
    /// Returns a `URL` that can be resolved by another `ApiClient`.
    func resolvableUrl(from instance: ContentModelUrlType) -> URL {
        switch instance {
        case .host: actorId.url
        case .provider: .comment(host: api.host, id: id)
        }
    }
    
    var depth: Int { parentCommentIds.count }
    
    func upgrade() async throws -> any DeprecatedComment {
        try await updateQueue.addUpgrade {
            let snapshot = try await self.api.repository.getComment(id: self.id)
            let comment = await self.api.caches.comment2.performModelTranslation(api: self.api, from: snapshot)
            return (snapshot, comment)
        }
    }
    
    func getChildren(
        sort: CommentSortType = .hot,
        includedParentCount: Int = 0,
        page: Int,
        maxDepth: Int? = nil,
        limit: Int,
        filter: GetContentFilter? = nil
    ) async throws -> [Comment2] {
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
    
    func updateRemoved(_ newValue: Bool, reason: String?, callback: ((UpdateStatus) -> Void)?) {
        comment1.removed = newValue
        comment1.removedPending = true
        Task {
            await updateQueue.addItem {
                do {
                    let ret = try await self.api.repository.removeComment(id: self.id, remove: newValue, reason: reason)
                    callback?(.success)
                    return ret
                } catch {
                    callback?(.failure(error))
                    throw (error)
                }
            }
        }
    }
    
    func reply(content: String, languageId: Int? = nil) async throws -> Comment2 {
        try await api.replyToComment(postId: postId, parentId: id, content: content, languageId: languageId)
    }
    
    func report(reason: String) async throws {
        try await api.reportComment(id: id, reason: reason)
    }
    
    func purge(reason: String?) async throws {
        try await api.purgeComment(id: id, reason: reason)
    }
    
    func updateDeleted(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        comment1.deleted = newValue
        Task {
            await updateQueue.addItem {
                do {
                    let ret = try await self.api.repository.deleteComment(id: self.id, delete: newValue)
                    callback?(.success)
                    return ret
                } catch {
                    callback?(.failure(error))
                    throw (error)
                }
            }
        }
    }
    
    func edit(
        content: String,
        languageId: Int?
    ) async throws {
        comment1.content = content
        if let languageId {
            comment1.languageId = languageId
        }
        Task {
            await updateQueue.addItem {
                try await self.api.repository.editComment(id: self.id, content: content, languageId: languageId)
            }
        }
    }
    
    // Get the parent comment, or return `nil` if there is no parent
    func getParent(cachedValueAcceptable: Bool = false) async throws -> Comment2? {
        if let parentId = parentCommentIds.last {
            if cachedValueAcceptable, let comment = api.caches.comment2.retrieveModel(cacheId: parentId) { return comment }
            return try await api.getComment(id: parentId)
        }
        return nil
    }
    
    func getParents() async throws -> [Comment2] {
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
    
    var parentCommentId: Int? { parentCommentIds.last }
    
    func getVotes(page: Int, limit: Int, communityId: Int) async throws -> [PersonVote] {
        try await api.getCommentVotes(id: id, communityId: communityId, page: page, limit: limit)
    }
}
