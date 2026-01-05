//
//  UnifiedPostModel.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-12-18.
//

import Observation
import Foundation
import Haptics
import os
import Nuke
import Rest

public class ExpectedValue<T> {
    let getValue: () -> T?
    let provideValue: () async throws -> Void
    
    /// Provides the value currently stored in this ExpectedValue. If the value is not present,
    /// it is automatically fetched
    public var value: T? {
        get {
            if let ret = getValue() { return ret }
            Task {
                do {
                    try await provideValue()
                } catch {
                    print(error)
                }
            }
            return nil
        }
    }
    
    // TODO: NOW should this even exist? Is this useful?
    /// Provides the value currently stored in this ExpectedValue. DOES NOT automatically fetch
    /// if the value is not present.
    public var value_: T? { getValue() }
    
    init(getValue: @escaping () -> T?, provideValue: @escaping () async throws -> Void) {
        self.getValue = getValue
        self.provideValue = provideValue
    }
}

public struct PostProperties: UnifiedPropertiesProviding {
    public typealias Snapshot = PostSnapshotProviding
    
    // From Post1Snapshot
    var actorId: ActorIdentifier?
    var id: Int?
    var creatorId: Int?
    var communityId: Int?
    var created: Date?
    var title: String?
    var content: String??
    var linkUrl: URL??
    var embed: PostEmbed??
    var nsfw: Bool?
    var thumbnailUrl: URL??
    var updated: Date??
    var languageId: Int?
    var altText: String??
    var deleted: Bool?
    var removed: Bool?
    var pinnedCommunity: Bool?
    var pinnedInstance: Bool?
    var locked: Bool?
    
    // From Post2Snapshot
    var creator: (any Person)?
    var community: (any Community)?
    var commentCount: Int?
    var unreadCommentCount: Int?
    var creatorIsModerator: Bool?
    var creatorIsAdmin: Bool?
    var creatorBannedFromCommunity: Bool?
    var creatorBlocked: Bool?
    var votes: VotesModel?
    var saved: Bool?
    var read: Bool?
    var hidden: Bool?
    
    @MainActor
    public mutating func update(with properties: Self) {
        actorId = properties.actorId ?? actorId
        id = properties.id ?? id
        creatorId = properties.creatorId ?? creatorId
        communityId = properties.communityId ?? communityId
        created = properties.created ?? created
        title = properties.title ?? title
        content = properties.content ?? content
        linkUrl = properties.linkUrl ?? linkUrl
        embed = properties.embed ?? embed
        nsfw = properties.nsfw ?? nsfw
        thumbnailUrl = properties.thumbnailUrl ?? thumbnailUrl
        updated = properties.updated ?? updated
        languageId = properties.languageId ?? languageId
        altText = properties.altText ?? altText
        deleted = properties.deleted ?? deleted
        removed = properties.removed ?? removed
        pinnedCommunity = properties.pinnedCommunity ?? pinnedCommunity
        pinnedInstance = properties.pinnedInstance ?? pinnedInstance
        locked = properties.locked ?? locked

        creator = properties.creator ?? creator
        community = properties.community ?? community
        commentCount = properties.commentCount ?? commentCount
        unreadCommentCount = properties.unreadCommentCount ?? unreadCommentCount
        creatorIsModerator = properties.creatorIsModerator ?? creatorIsModerator
        creatorIsAdmin = properties.creatorIsAdmin ?? creatorIsAdmin
        creatorBannedFromCommunity = properties.creatorBannedFromCommunity ?? creatorBannedFromCommunity
        creatorBlocked = properties.creatorBlocked ?? creatorBlocked
        votes = properties.votes ?? votes
        saved = properties.saved ?? saved
        read = properties.read ?? read
        hidden = properties.hidden ?? hidden
    }
    
    /// Constructs an empty PostProperties
    public init() {}
    
    /// Constructs a PostProperties from a given snapshot
    public init(snapshot: any PostSnapshotProviding) {
        let snapshot2: Post2Snapshot?
        let snapshot1: Post1Snapshot?
        
        if let snapshot3 = snapshot as? Post3Snapshot {
            // Post3Snapshot-specific properties all must be explicitly passed in
            snapshot2 = snapshot3.post
        } else {
            snapshot2 = snapshot as? Post2Snapshot
        }
        
        if let snapshot2 {
            snapshot1 = snapshot2.post
            
            commentCount = snapshot2.commentCount
            unreadCommentCount = snapshot2.unreadCommentCount
            creatorIsModerator = snapshot2.creatorIsModerator
            creatorIsAdmin = snapshot2.creatorIsAdmin
            creatorBannedFromCommunity = snapshot2.creatorBannedFromCommunity
            creatorBlocked = snapshot2.creatorBlocked
            votes = snapshot2.votes
            saved = snapshot2.saved
            read = snapshot2.read
            hidden = snapshot2.hidden
        } else {
            snapshot1 = snapshot as? Post1Snapshot
        }
        
        if let snapshot1 {
            actorId = snapshot1.actorId
            id = snapshot1.id
            creatorId = snapshot1.creatorId
            communityId = snapshot1.communityId
            created = snapshot1.created
            title = snapshot1.title
            content = snapshot1.content
            linkUrl = snapshot1.linkUrl
            embed = snapshot1.embed
            nsfw = snapshot1.nsfw
            thumbnailUrl = snapshot1.thumbnailUrl
            updated = snapshot1.updated
            languageId = snapshot1.languageId
            altText = snapshot1.altText
            deleted = snapshot1.deleted
            removed = snapshot1.removed
            pinnedCommunity = snapshot1.pinnedCommunity
            pinnedInstance = snapshot1.pinnedInstance
            locked = snapshot1.locked
        }
    }
    
    /// Constructs a PostProperties from a given snapshot, including external models
    public init(snapshot: any PostSnapshotProviding, creator: (any Person)?, community: (any Community)?) {
        self.init(snapshot: snapshot)
        self.creator = creator
        self.community = community
    }
}

public protocol UnifiedPropertiesProviding {
    @MainActor mutating func update(with properties: Self)
}

public protocol UnifiedModelProviding: AnyObject, CacheIdentifiable, ContentModel {
    associatedtype Properties: UnifiedPropertiesProviding
    
    var properties: Properties { get set }
    func fetchUpgraded() async throws -> Properties
}

@Observable
public class UnifiedPostModel: UnifiedModelProviding, FeedLoadable {
    public typealias Properties = PostProperties
    
    @ObservationIgnored
    lazy var updateQueue: UnifiedUpdateQueue<UnifiedPostModel> = .init(parent: self)
    
    public var api: ApiClient
    public var actorId: ActorIdentifier
    public var properties: PostProperties
    
    public var url: URL { actorId.url }
    
    public init(api: ApiClient, url: URL) {
        self.api = api
        self.actorId = .init(url: url)!
        self.properties = .init()
    }
    
    public init(api: ApiClient, snapshot: any PostSnapshotProviding, creator: (any Person)? = nil, community: (any Community)? = nil) {
        self.api = api
        self.actorId = snapshot.actorId
        self.properties = .init(snapshot: snapshot, creator: creator, community: community)
    }
    
    private func expectedValue<T>(_ keyPath: WritableKeyPath<PostProperties, T?>) -> ExpectedValue<T> {
        .init(
            getValue: { self.properties[keyPath: keyPath] },
            provideValue: { try await self.upgrade() })
    }
    
    // TODO: NOW do this better
    public var cacheId: Int { actorId.hashValue }
    public static var tierNumber: Int =  4
    
//    @ObservationIgnored
//    public lazy var actorId: ExpectedValue<ActorIdentifier> = expectedValue(\.actorId)
    
    @ObservationIgnored
    public lazy var id: ExpectedValue<Int> = expectedValue(\.id)

    @ObservationIgnored
    public lazy var creatorId: ExpectedValue<Int> = expectedValue(\.creatorId)

    @ObservationIgnored
    public lazy var communityId: ExpectedValue<Int> = expectedValue(\.communityId)

    @ObservationIgnored
    public lazy var created: ExpectedValue<Date> = expectedValue(\.created)

    @ObservationIgnored
    public lazy var title: ExpectedValue<String> = expectedValue(\.title)

    @ObservationIgnored
    public lazy var content: ExpectedValue<String?> = expectedValue(\.content)

    @ObservationIgnored
    public lazy var linkUrl: ExpectedValue<URL?> = expectedValue(\.linkUrl)

    @ObservationIgnored
    public lazy var embed: ExpectedValue<PostEmbed?> = expectedValue(\.embed)

    @ObservationIgnored
    public lazy var nsfw: ExpectedValue<Bool> = expectedValue(\.nsfw)

    @ObservationIgnored
    public lazy var thumbnailUrl: ExpectedValue<URL?> = expectedValue(\.thumbnailUrl)

    @ObservationIgnored
    public lazy var updated: ExpectedValue<Date?> = expectedValue(\.updated)

    @ObservationIgnored
    public lazy var languageId: ExpectedValue<Int> = expectedValue(\.languageId)

    @ObservationIgnored
    public lazy var altText: ExpectedValue<String?> = expectedValue(\.altText)

    @ObservationIgnored
    public lazy var deleted: ExpectedValue<Bool> = expectedValue(\.deleted)

    @ObservationIgnored
    public lazy var removed: ExpectedValue<Bool> = expectedValue(\.removed)

    @ObservationIgnored
    public lazy var pinnedCommunity: ExpectedValue<Bool> = expectedValue(\.pinnedCommunity)

    @ObservationIgnored
    public lazy var pinnedInstance: ExpectedValue<Bool> = expectedValue(\.pinnedInstance)

    @ObservationIgnored
    public lazy var locked: ExpectedValue<Bool> = expectedValue(\.locked)

    @ObservationIgnored
    public lazy var creator: ExpectedValue<any Person> = expectedValue(\.creator)
    
    @ObservationIgnored
    public lazy var community: ExpectedValue<any Community> = expectedValue(\.community)
    
    @ObservationIgnored
    public lazy var commentCount: ExpectedValue<Int> = expectedValue(\.commentCount)

    @ObservationIgnored
    public lazy var unreadCommentCount: ExpectedValue<Int> = expectedValue(\.unreadCommentCount)

    @ObservationIgnored
    public lazy var creatorIsModerator: ExpectedValue<Bool> = expectedValue(\.creatorIsModerator)

    @ObservationIgnored
    public lazy var creatorIsAdmin: ExpectedValue<Bool> = expectedValue(\.creatorIsAdmin)

    @ObservationIgnored
    public lazy var creatorBannedFromCommunity: ExpectedValue<Bool> = expectedValue(\.creatorBannedFromCommunity)

    @ObservationIgnored
    public lazy var creatorBlocked: ExpectedValue<Bool> = expectedValue(\.creatorBlocked)

    @ObservationIgnored
    public lazy var votes: ExpectedValue<VotesModel> = expectedValue(\.votes)

    @ObservationIgnored
    public lazy var saved: ExpectedValue<Bool> = expectedValue(\.saved)

    @ObservationIgnored
    public lazy var read: ExpectedValue<Bool> = expectedValue(\.read)

    @ObservationIgnored
    public lazy var hidden: ExpectedValue<Bool> = expectedValue(\.hidden)
    
    internal func upgrade() async throws {
        try await updateQueue.upgrade()
    }
    
    @discardableResult
    public func fetchUpgraded() async throws -> PostProperties {
        Logger.dev.info("Fetching upgraded...")
        
        var id: Int
        if let existingId = properties.id {
            id = existingId
        } else {
            id = try await api.repository.getPost(url: self.url).post.id
        }
        
        let snapshot = try await api.repository.getPost(id: id)
        let creator = await api.caches.person1.getModel(api: api, from: snapshot.post.creator)
        let community = await api.caches.community1.getModel(api: api, from: snapshot.post.community)
        
        // TODO: NOW repository provides properties?
        return .init(snapshot: snapshot, creator: creator, community: community)
    }
}

// MARK: - Interactions

public extension UnifiedPostModel {
    // Save
    
    var updateSaved: ((Bool) -> Void)? {
        if let id = id.value {
            return { self.updateSaved($0, id: id) }
        }
        return nil
    }
    
    private func updateSaved(_ newValue: Bool, id: Int) {
        properties.saved = newValue
        properties.read = true
        
        Task {
            await updateQueue.addItem {
                .init(snapshot: try await self.api.repository.savePost(id: id, save: newValue))
            }
        }
    }
    
    // Vote
    
    var updateVote: ((ScoringOperation) -> Void)? {
        if let votes = votes.value, let id = id.value {
            return { self.updateVote($0, votes: votes, id: id) }
        }
        return nil
    }
    
    private func updateVote(_ newValue: ScoringOperation, votes: VotesModel, id: Int) {
        properties.votes = votes.applyScoringOperation(operation: newValue)
        properties.read = true
        
        Task {
            await updateQueue.addItem {
                .init(snapshot: try await self.api.repository.voteOnPost(id: id, score: newValue))
            }
        }
    }
}

// MARK: - FeedLoadable

public extension UnifiedPostModel {
    typealias FilterType = PostFilterType
    
    static func == (lhs: UnifiedPostModel, rhs: UnifiedPostModel) -> Bool {
        lhs.actorId == rhs.actorId
    }
    
    // TODO: NOW rethink sort val for async dates
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            return .new(created.value_ ?? Date())
        }
    }
}

// MARK: - ImagePrefetchProviding

extension UnifiedPostModel: ImagePrefetchProviding {
    var type: PostType {
        // post with URL: image, embedded, or link
        if let linkUrl = linkUrl.value_ as? URL,
           let title = title.value_ {
//            if let embeddedMediaUrl {
//                return .embedded(embeddedMediaUrl, originalLink: linkUrl)
//            }
            
            // if image, return image link, otherwise return thumbnail
            if linkUrl.isMedia {
                return .media(linkUrl)
            }
            return .link(.init(content: linkUrl, thumbnail: thumbnailUrl.value_ as? URL, label: embed.value_??.title ?? title))
        }

        // otherwise text, but post.body needs to be present, even if it's an empty string
        if let postBody = content.value_ as? String {
            return .text(postBody)
        }

        return .titleOnly
    }
    
    func parseLoopEmbeds() async {
        // TODO: NOW not noop
//        if let loopsUrl = await linkUrl.value_??.parseEmbeddedLoops() {
//            _ = await Task { @MainActor in
//                properties.embeddedMediaUrl = loopsUrl
//            }.result
//        }
    }
    
    public func imageRequests(configuration config: PrefetchingConfiguration) async -> [ImageRequest] {
        var ret: [ImageRequest] = .init()
        
        // handle loops.video embedding
        if config.embedLoops {
            await parseLoopEmbeds()
        }
        
        switch type {
        case let .media(url), let .embedded(url, _):
            // media/embedded media: only load the media
            var urlRequest: URLRequest
            switch config.imageSize {
            case .unlimited:
                urlRequest = mlemUrlRequest(url: url)
            case let .limited(size):
                urlRequest = mlemUrlRequest(url: url.withIconSize(size))
            }
            ret.append(ImageRequest(urlRequest: urlRequest, priority: .high))
        case let .link(link):
            // websites: load image and favicon
            if config.fetchFavicons, let url = link.favicon {
                let urlRequest = mlemUrlRequest(url: url)
                ret.append(ImageRequest(urlRequest: urlRequest))
            }
            if let url = link.thumbnail {
                var urlRequest: URLRequest
                switch config.imageSize {
                case .unlimited:
                    urlRequest = mlemUrlRequest(url: url)
                case let .limited(size):
                    urlRequest = mlemUrlRequest(url: url.withIconSize(size))
                }
                ret.append(ImageRequest(urlRequest: urlRequest, priority: .high))
            }
        default:
            break
        }
        // preload user and community avatars--fetching both because we don't know which we'll need, but these are super tiny
        // so it's probably not an API crime, right?
        if let avatarSize = config.avatarSize {
            if let communityAvatarLink = community.value_?.avatar {
                ret.append(ImageRequest(urlRequest: mlemUrlRequest(url: communityAvatarLink.withIconSize(avatarSize))))
            }
            
            if let userAvatarLink = creator.value_?.avatar {
                ret.append(ImageRequest(urlRequest: mlemUrlRequest(url: userAvatarLink.withIconSize(avatarSize))))
            }
        }
        
        return ret
    }
}
