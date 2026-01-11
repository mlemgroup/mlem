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

// TODO: New Interactable remove Interactable1Providing conformance
@Observable
public class UnifiedPostModel:
    UnifiedModelProviding,
    FeedLoadable,
    SelectableContentProviding,
    ContentIdentifiable,
    Resolvable,
    Sharable,
    UnifiedReadableProviding,
    Interactable1Providing {
    public typealias Properties = PostProperties
    
    public init(api: ApiClient, snapshot: any PostSnapshotProviding, creator: (any Person)? = nil, community: (any Community)? = nil) {
        self.api = api
        self.properties = .init(snapshot: snapshot, creator: creator, community: community)
    }
    
    // MARK: Core
    
    @ObservationIgnored
    lazy var updateQueue: UnifiedUpdateQueue<UnifiedPostModel> = .init(parent: self)
    public var api: ApiClient
    public var properties: PostProperties
    
    internal func upgrade() async throws {
        try await updateQueue.upgrade()
    }
    
    public func fetchUpgraded() async throws -> PostProperties {
        let snapshot = try await api.repository.getPost(id: id)
        let creator = await api.caches.person1.getModel(api: api, from: snapshot.post.creator)
        let community = await api.caches.community1.getModel(api: api, from: snapshot.post.community)
        
        // TODO: NOW repository provides properties?
        return .init(snapshot: snapshot, creator: creator, community: community)
    }
    
    // MARK: Properties
    
    private func expectedValue<T>(_ keyPath: WritableKeyPath<PostProperties, T?>) -> ExpectedValue<T> {
        .init(
            getValue: { self.properties[keyPath: keyPath] },
            provideValue: { try await self.upgrade() })
    }
    
    public var actorId: ActorIdentifier { properties.actorId }
    
    public var id: Int { properties.id }
    
    public var creatorId: Int { properties.creatorId }
    
    public var communityId: Int { properties.communityId }
    
    public var created: Date { properties.created }
    
    public var title: String { properties.title }
    
    public var content: String? { properties.content }
    
    public var linkUrl: URL? { properties.linkUrl }
    
    public var embed: PostEmbed? { properties.embed }
    
    public var nsfw: Bool { properties.nsfw }
    
    public var thumbnailUrl: URL? { properties.thumbnailUrl }
    
    public var updated: Date? { properties.updated }
    
    public var languageId: Int { properties.languageId }
    
    public var altText: String? { properties.altText }
    
    public var deleted: Bool { properties.deleted }
    
    public var removed: Bool { properties.removed }
    
    public var pinnedCommunity: Bool { properties.pinnedCommunity }
    
    public var pinnedInstance: Bool { properties.pinnedInstance }
    
    public var locked: Bool { properties.locked }

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
}

// MARK: - Computed

public extension UnifiedPostModel {
    var linkHost: String? {
        if case let .link(link) = type {
            return link.host
        }
        return nil
    }
}

// MARK: - Interactions

public extension UnifiedPostModel {

    func updateSaved(_ newValue: Bool) {
        properties.saved = newValue
        properties.read = true
        
        Task {
            await updateQueue.addItem {
                .init(snapshot: try await self.api.repository.savePost(id: self.id, save: newValue))
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
        properties.votes = votes.applyScoringOperation(operation: newValue)
        properties.read = true
        
        Task {
            await updateQueue.addItem {
                .init(snapshot: try await self.api.repository.voteOnPost(id: self.id, score: newValue))
            }
        }
    }
    
    // Reply
    
    func reply(content: String, languageId: Int?) async throws -> Comment2 {
        try await self.api.replyToPost(id: id, content: content, languageId: languageId)
    }
    
    // Hide
    
    func updateHidden(_ newValue: Bool) {
        properties.hidden = newValue
        properties.read = true
        
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
    
    func updateRead(_ newValue: Bool) {
        // TODO: NOW queueing
        properties.read = newValue
        
        Task {
            await updateQueue.addItem { properties in
                try await self.api.repository.markPostAsRead(id: self.id, read: newValue)
                var properties = properties
                properties.read = newValue
                return properties
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
}
