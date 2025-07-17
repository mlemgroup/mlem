//
//  Post1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

public protocol Post1Providing:
    PostStubProviding,
    ActorIdentifiable,
    ContentIdentifiable,
    Interactable1Providing,
    SelectableContentProviding,
    DeletableProviding,
    RemovableProviding,
    PurgableProviding,
    ImagePrefetchProviding,
    Sharable,
    FeedLoadable where FilterType == PostFilterType {
    var post1: Post1 { get }
    
    var id: Int { get }
    var creatorId: Int { get }
    var communityId: Int { get }
    var title: String { get }
    var content: String? { get }
    var linkUrl: URL? { get }
    var embeddedMediaUrl: URL? { get }
    var deleted: Bool { get }
    var embed: PostEmbed? { get }
    var pinnedCommunity: Bool { get }
    var pinnedInstance: Bool { get }
    var locked: Bool { get }
    var pinnedCommunityManager: StateManager<Bool> { get }
    var pinnedInstanceManager: StateManager<Bool> { get }
    var lockedManager: StateManager<Bool> { get }
    var nsfw: Bool { get }
    var created: Date { get }
    var thumbnailUrl: URL? { get }
    var updated: Date? { get }
    var languageId: Int { get }
    var altText: String? { get }
    
    func snapshotUpdate(with snapshot: any PostSnapshotProviding)
    func takeSnapshot() -> any PostSnapshotProviding
    var updateQueue: PostUpdateQueue { get }
}

public typealias Post = Post1Providing

public extension Post1Providing {
    static var modelTypeId: ContentType { .post }
    
    var actorId: ActorIdentifier { post1.actorId }
    var id: Int { post1.id }
    var creatorId: Int { post1.creatorId }
    var communityId: Int { post1.communityId }
    var title: String { post1.title }
    var content: String? { post1.content }
    var linkUrl: URL? { post1.linkUrl }
    var embeddedMediaUrl: URL? { post1.embeddedMediaUrl }
    var deleted: Bool { post1.deleted }
    var embed: PostEmbed? { post1.embed }
    var pinnedCommunity: Bool { post1.pinnedCommunity }
    var pinnedInstance: Bool { post1.pinnedInstance }
    var locked: Bool { post1.locked }
    var pinnedCommunityManager: StateManager<Bool> { post1.pinnedCommunityManager }
    var pinnedInstanceManager: StateManager<Bool> { post1.pinnedInstanceManager }
    var lockedManager: StateManager<Bool> { post1.lockedManager }
    var nsfw: Bool { post1.nsfw }
    var created: Date { post1.created }
    var removed: Bool { post1.removed }
    var removedManager: StateManager<Bool> { post1.removedManager }
    var thumbnailUrl: URL? { post1.thumbnailUrl }
    var updated: Date? { post1.updated }
    var languageId: Int { post1.languageId }
    var altText: String? { post1.altText }
    var purged: Bool { post1.purged }
    
    var actorId_: ActorIdentifier? { actorId }
    var creatorId_: Int? { post1.creatorId }
    var communityId_: Int? { post1.communityId }
    var title_: String? { post1.title }
    var content_: String? { post1.content }
    var linkUrl_: URL? { post1.linkUrl }
    var deleted_: Bool? { post1.deleted }
    var embed_: PostEmbed? { post1.embed }
    var pinnedCommunity_: Bool? { post1.pinnedCommunity }
    var pinnedInstance_: Bool? { post1.pinnedInstance }
    var locked_: Bool? { post1.locked }
    var pinnedCommunityManager_: StateManager<Bool>? { post1.pinnedCommunityManager }
    var pinnedInstanceManager_: StateManager<Bool>? { post1.pinnedInstanceManager }
    var lockedManager_: StateManager<Bool>? { post1.lockedManager }
    var nsfw_: Bool? { post1.nsfw }
    var created_: Date? { post1.created }
    var removed_: Bool? { post1.removed }
    var removedManager_: StateManager<Bool>? { post1.removedManager }
    var thumbnailUrl_: URL? { post1.thumbnailUrl }
    var updated_: Date? { post1.updated }
    var languageId_: Int? { post1.languageId }
    var altText_: String? { post1.altText }
}

// snapshot methods
extension Post1Providing {
    public func snapshotUpdate(with snapshot: any PostSnapshotProviding) {
        if let post3snapshot = snapshot as? Post3Snapshot {
            snapshot1Update(with: post3snapshot.post.post)
        } else if let post2snapshot = snapshot as? Post2Snapshot {
            snapshot1Update(with: post2snapshot.post)
        } else if let post1snapshot = snapshot as? Post1Snapshot {
            snapshot1Update(with: post1snapshot)
        } else {
            assertionFailure("Unrecognized post snapshot")
        }
    }
    
    internal func snapshot1Update(with snapshot: Post1Snapshot) {
        post1.title = snapshot.title
        post1.content = snapshot.content
        post1.linkUrl = snapshot.linkUrl
        post1.embed = snapshot.embed
        post1.nsfw = snapshot.nsfw
        post1.thumbnailUrl = snapshot.thumbnailUrl
        post1.updated = snapshot.updated
        post1.languageId = snapshot.languageId
        post1.altText = snapshot.altText
        //        self.deleted = snapshot.deleted
        //        self.removed = snapshot.removed
        //        self.pinnedCommunity = snapshot.pinnedCommunity
        //        self.pinnedInstance = snapshot.pinnedInstance
        //        self.locked = snapshot.locked
    }
    
    public func takeSnapshot() -> any PostSnapshotProviding {
        takeSnapshot1()
    }
    
    public func takeSnapshot1() -> Post1Snapshot {
        .init(
            actorId: actorId,
            id: id,
            creatorId: creatorId,
            communityId: communityId,
            created: created,
            title: title,
            content: content,
            linkUrl: linkUrl,
            embed: embed,
            nsfw: nsfw,
            thumbnailUrl: thumbnailUrl,
            updated: updated,
            languageId: languageId,
            altText: altText,
            deleted: deleted,
            removed: removed,
            pinnedCommunity: pinnedCommunity,
            pinnedInstance: pinnedInstance,
            locked: locked
        )
    }
}

// Resolvable conformance
public extension Post1Providing {
    @inlinable
    var allResolvableUrls: [URL] {
        ContentModelUrlType.allCases.map { resolvableUrl(from: $0) }
    }
}

// Sharable conformance
public extension Post1Providing {
    func url() -> URL { api.baseUrl.appending(path: "post/\(id)") }
}

// FeedLoadable conformance
public extension Post1Providing {
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            return .new(created)
        }
    }
}

// SelectableContentProviding conformance
public extension Post1Providing {
    var selectableContent: String? {
        if let content {
            "\(title)\n\n\(content)"
        } else {
            title
        }
    }
}

public extension Post1Providing {
    /// Returns a `URL` that can be resolved by another `ApiClient`.
    func resolvableUrl(from instance: ContentModelUrlType) -> URL {
        switch instance {
        case .host: actorId.url
        case .provider: .post(host: api.host, id: id)
        }
    }
    
    /// If this post links to loops.video, attempts to parse the underlying media url and set embeddedMediaUrl
    func parseLoopEmbeds() async {
        if let loopsUrl = await linkUrl?.parseEmbeddedLoops() {
            _ = await Task { @MainActor in
                post1.embeddedMediaUrl = loopsUrl
            }.result
        }
    }
    
    var type: PostType {
        // post with URL: image, embedded, or link
        if let linkUrl {
            if let embeddedMediaUrl {
                return .embedded(embeddedMediaUrl, originalLink: linkUrl)
            }
            
            // if image, return image link, otherwise return thumbnail
            if linkUrl.isMedia {
                return .media(linkUrl)
            }
            return .link(.init(content: linkUrl, thumbnail: thumbnailUrl, label: embed?.title ?? title))
        }

        // otherwise text, but post.body needs to be present, even if it's an empty string
        if let postBody = content {
            return .text(postBody)
        }

        return .titleOnly
    }
}

public extension Post1Providing {
    private var deletedManager: StateManager<Bool> { post1.deletedManager }

    func upgrade() async throws -> any Post {
        try await api.getPost(id: id)
    }
    
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
    
    func reply(content: String, languageId: Int? = nil) async throws -> Comment2 {
        try await api.replyToPost(id: id, content: content, languageId: languageId)
    }
    
    func report(reason: String) async throws {
        try await api.reportPost(id: id, reason: reason)
    }
    
    func purge(reason: String?) async throws {
        try await api.purgePost(id: id, reason: reason)
    }
    
    @discardableResult
    func updateDeleted(_ newValue: Bool) -> Task<StateUpdateResult, Never> {
        deletedManager.performRequest(expectedResult: newValue) { semaphore in
            try await self.api.deletePost(id: self.id, delete: newValue, semaphore: semaphore)
        }
    }
    
    func edit(
        title: String,
        content: String?,
        linkUrl: URL?,
        altText: String?,
        thumbnail: URL?,
        nsfw: Bool,
        languageId: Int?
    ) async throws {
        try await api.editPost(
            id: id,
            title: title,
            content: content,
            linkUrl: linkUrl,
            altText: altText,
            thumbnail: thumbnail,
            nsfw: nsfw,
            languageId: languageId
        )
    }
    
    @discardableResult
    func updateLocked(_ newValue: Bool) -> Task<StateUpdateResult, Never> {
        lockedManager.performRequest(expectedResult: newValue) { semaphore in
            try await self.api.lockPost(id: self.id, lock: newValue, semaphore: semaphore)
        }
    }
    
    @discardableResult
    func toggleLocked() -> Task<StateUpdateResult, Never> {
        updateLocked(!locked)
    }
    
    @discardableResult
    func updatePinnedCommunity(_ newValue: Bool) -> Task<StateUpdateResult, Never> {
        pinnedCommunityManager.performRequest(expectedResult: newValue) { semaphore in
            try await self.api.pinPost(id: self.id, pin: newValue, to: .community, semaphore: semaphore)
        }
    }
    
    @discardableResult
    func togglePinnedCommunity() -> Task<StateUpdateResult, Never> {
        updatePinnedCommunity(!pinnedCommunity)
    }
    
    @discardableResult
    func updatePinnedInstance(_ newValue: Bool) -> Task<StateUpdateResult, Never> {
        pinnedInstanceManager.performRequest(expectedResult: newValue) { semaphore in
            try await self.api.pinPost(id: self.id, pin: newValue, to: .instance, semaphore: semaphore)
        }
    }
    
    @discardableResult
    func togglePinnedInstance() -> Task<StateUpdateResult, Never> {
        updatePinnedInstance(!pinnedInstance)
    }
    
    @discardableResult
    func updateRemoved(_ newValue: Bool, reason: String?) -> Task<StateUpdateResult, Never> {
        removedManager.performRequest(expectedResult: newValue) { semaphore in
            try await self.api.removePost(id: self.id, remove: newValue, reason: reason, semaphore: semaphore)
        }
    }
    
    func getVotes(page: Int, limit: Int) async throws -> [PersonVote] {
        try await api.getPostVotes(id: id, communityId: communityId, page: page, limit: limit)
    }
}
