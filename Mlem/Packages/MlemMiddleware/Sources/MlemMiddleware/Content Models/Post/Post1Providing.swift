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
    CanModerateProviding,
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
    var pinnedCommunityPending: Bool { get }
    var pinnedInstance: Bool { get }
    var pinnedInstancePending: Bool { get }
    var locked: Bool { get }
    var lockedPending: Bool { get }
    var nsfw: Bool { get }
    var created: Date { get }
    var thumbnailUrl: URL? { get }
    var updated: Date? { get }
    var languageId: Int { get }
    var altText: String? { get }
    
    func snapshotUpdate(with snapshot: any PostSnapshotProviding) async
    func takeSnapshot() -> any PostSnapshotProviding
    var updateQueue: PostUpdateQueue { get }
}

public typealias Post = Post1Providing

public extension Post1Providing {
    static var modelTypeId: ContentType { .post }
    
    var updateQueue: PostUpdateQueue { post1.updateQueue }
    
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
    var pinnedCommunityPending: Bool { post1.pinnedCommunityPending }
    var pinnedInstance: Bool { post1.pinnedInstance }
    var pinnedInstancePending: Bool { post1.pinnedInstancePending }
    var locked: Bool { post1.locked }
    var lockedPending: Bool { post1.lockedPending }
    var nsfw: Bool { post1.nsfw }
    var nsfwPending: Bool { post1.nsfwPending }
    var created: Date { post1.created }
    var removed: Bool { post1.removed }
    var removedPending: Bool { post1.removedPending }
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
    var nsfw_: Bool? { post1.nsfw }
    var created_: Date? { post1.created }
    var removed_: Bool? { post1.removed }
    var thumbnailUrl_: URL? { post1.thumbnailUrl }
    var updated_: Date? { post1.updated }
    var languageId_: Int? { post1.languageId }
    var altText_: String? { post1.altText }
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

// ReportableProviding conformance
public extension Post1Providing {
    func isOwnContent(myPersonId: Int) -> Bool {
        creatorId == myPersonId
    }
}

// CanModerateProviding conformance
public extension Post1Providing {
    var canModerate: Bool {
        api.myPerson?.moderates(communityId: communityId) ?? false || api.isAdmin
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
    func upgrade() async throws -> any Post {
        try await updateQueue.addUpgrade {
            let snapshot = try await self.api.repository.getPost(id: self.id)
            let post = await self.api.caches.post3.performModelTranslation(api: self.api, from: snapshot)
            return (snapshot, post)
        }
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
    
    func updateDeleted(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        post1.deleted = newValue
        Task {
            await updateQueue.addItem {
                do {
                    let snapshot = try await self.api.repository.deletePost(id: self.id, delete: newValue)
                    callback?(.success)
                    return snapshot
                } catch {
                    callback?(.failure(error))
                    throw error
                }
            }
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
    ) throws {
        post1.title = title
        post1.content = content
        post1.linkUrl = linkUrl
        post1.altText = altText
        post1.thumbnailUrl = thumbnail
        post1.nsfw = nsfw
        post1.languageId = languageId ?? post1.languageId
        Task {
            await updateQueue.addItem {
                try await self.api.repository.editPost(
                    id: self.id,
                    title: title,
                    content: content,
                    linkUrl: linkUrl,
                    altText: altText,
                    thumbnail: thumbnail,
                    nsfw: nsfw,
                    languageId: languageId
                )
            }
        }
    }
    
    /// Locks or unlocks this post according to newValue
    /// - Parameters:
    ///   - newValue: true to lock post, false to unlock
    ///   - callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func updateLocked(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        post1.locked = newValue
        post1.lockedPending = true
        Task {
            await updateQueue.addItem {
                do {
                    let ret = try await self.api.repository.lockPost(id: self.id, lock: newValue)
                    callback?(.success)
                    return ret
                } catch {
                    callback?(.failure(error))
                    throw (error)
                }
            }
        }
    }
    
    /// Toggles the locked status of this post
    /// - Parameter callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func toggleLocked(callback: ((UpdateStatus) -> Void)? = nil) {
        updateLocked(!locked, callback: callback)
    }
    
    /// Pins or unpins this post to the community according to newValue
    /// - Parameters:
    ///   - newValue: true to pin post, false to unpin
    ///   - callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func updatePinnedCommunity(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        post1.pinnedCommunity = newValue
        post1.pinnedCommunityPending = true
        Task {
            await updateQueue.addItem {
                do {
                    let ret = try await self.api.repository.pinPost(id: self.id, pin: newValue, to: .community)
                    callback?(.success)
                    return ret
                } catch {
                    callback?(.failure(error))
                    throw error
                }
            }
        }
    }
    
    /// Toggles the community pinned status of this post
    /// - Parameter callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func togglePinnedCommunity(callback: ((UpdateStatus) -> Void)? = nil) {
        updatePinnedCommunity(!pinnedCommunity, callback: callback)
    }
    
    /// Pins or unpins this post to the instance according to newValue
    /// - Parameters:
    ///   - newValue: true to pin post, false to unpin
    ///   - callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func updatePinnedInstance(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        post1.pinnedInstance = newValue
        post1.pinnedInstancePending = true
        Task {
            await updateQueue.addItem {
                do {
                    let ret = try await self.api.repository.pinPost(id: self.id, pin: newValue, to: .instance)
                    callback?(.success)
                    return ret
                } catch {
                    callback?(.failure(error))
                    throw error
                }
            }
        }
    }
    
    /// Toggles the instance pinned status of this post
    /// - Parameter callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func togglePinnedInstance(callback: ((UpdateStatus) -> Void)? = nil) {
        updatePinnedInstance(!pinnedInstance, callback: callback)
    }
    
    /// Removes or restores this post according to newValue
    /// - Parameters:
    ///   - newValue: true to remove post, false to restore
    ///   - callback: if present, when the repository call completes, is called with `.success` if the operation succeeded and `.failure` otherwise.
    func updateRemoved(_ newValue: Bool, reason: String?, callback: ((UpdateStatus) -> Void)?) {
        post1.removed = newValue
        post1.removedPending = true
        Task {
            await updateQueue.addItem {
                do {
                    let ret = try await self.api.repository.removePost(id: self.id, remove: newValue, reason: reason)
                    callback?(.success)
                    return ret
                } catch {
                    callback?(.failure(error))
                    throw (error)
                }
            }
        }
    }
    
    func updateNsfw(_ newValue: Bool, callback: ((UpdateStatus) -> Void)?) {
        post1.nsfw = newValue
        post1.nsfwPending = true
        Task {
            await updateQueue.addItem {
                do {
                    let ret = try await self.api.repository.setPostNsfw(id: self.id, nsfw: newValue)
                    callback?(.success)
                    return ret
                } catch {
                    callback?(.failure(error))
                    throw (error)
                }
            }
        }
    }
    
    func toggleNsfw(callback: ((UpdateStatus) -> Void)?) {
        updateNsfw(!nsfw, callback: callback)
    }

    func getVotes(page: Int, limit: Int) async throws -> [PersonVote] {
        try await api.getPostVotes(id: id, communityId: communityId, page: page, limit: limit)
    }
}
