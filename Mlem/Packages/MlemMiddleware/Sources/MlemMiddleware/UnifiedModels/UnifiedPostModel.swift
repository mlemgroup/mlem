//
//  UnifiedPostModel.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2025-12-18.
//

import Observation
import Foundation
import os

public class ExpectedValue<T> {
    let getValue: () -> T?
    let provideValue: () async throws -> Void
    
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
    
    // TODO: crossposts and post/community (needs caching)
    
    @MainActor
    public mutating func update(with snapshot: any PostSnapshotProviding) {
        if let snapshot3 = snapshot as? Post3Snapshot {
            snapshot3Update(with: snapshot3)
        } else if let snapshot2 = snapshot as? Post2Snapshot {
            snapshot2Update(with: snapshot2)
        } else if let snapshot1 = snapshot as? Post1Snapshot {
            snapshot1Update(with: snapshot1)
        } else {
            assertionFailure("Unrecognized post snapshot")
        }
    }
    
    private mutating func snapshot1Update(with snapshot: Post1Snapshot) {
        actorId = snapshot.actorId
        id = snapshot.id
        creatorId = snapshot.creatorId
        communityId = snapshot.communityId
        created = snapshot.created
        title = snapshot.title
        content = snapshot.content
        linkUrl = snapshot.linkUrl
        embed = snapshot.embed
        nsfw = snapshot.nsfw
        thumbnailUrl = snapshot.thumbnailUrl
        updated = snapshot.updated
        languageId = snapshot.languageId
        altText = snapshot.altText
        deleted = snapshot.deleted
        removed = snapshot.removed
        pinnedCommunity = snapshot.pinnedCommunity
        pinnedInstance = snapshot.pinnedInstance
        locked = snapshot.locked
    }
    
    private mutating func snapshot2Update(with snapshot: Post2Snapshot) {
        commentCount = snapshot.commentCount
        unreadCommentCount = snapshot.unreadCommentCount
        creatorIsModerator = snapshot.creatorIsModerator
        creatorIsAdmin = snapshot.creatorIsAdmin
        creatorBannedFromCommunity = snapshot.creatorBannedFromCommunity
        creatorBlocked = snapshot.creatorBlocked
        votes = snapshot.votes
        saved = snapshot.saved
        read = snapshot.read
        hidden = snapshot.hidden
        
        snapshot1Update(with: snapshot.post)
    }
    
    private mutating func snapshot3Update(with snapshot: Post3Snapshot) {
        // TODO: assign properties
        
        snapshot2Update(with: snapshot.post)
    }
    
    public static func merge(_ snapshot: any PostSnapshotProviding, into target: any PostSnapshotProviding) -> PostSnapshotProviding {
        snapshot.merge(with: target)
    }
}

public protocol UnifiedPropertiesProviding {
    associatedtype Snapshot
    
    @MainActor mutating func update(with snapshot: Snapshot)
    
    static func merge(_ snapshot: Snapshot, into target: Snapshot) -> Snapshot
}

public protocol UnifiedModelProviding: AnyObject {
    associatedtype Properties: UnifiedPropertiesProviding
    
    var properties: Properties { get set }
    func fetchUpgraded() async throws -> Properties.Snapshot
}

@Observable
public class UnifiedPostModel: UnifiedModelProviding {
    public typealias Properties = PostProperties
    
    @ObservationIgnored
    lazy var updateQueue: UnifiedUpdateQueue<UnifiedPostModel> = .init(parent: self)
    
    public var api: ApiClient
    public var url: URL
    
    public init(api: ApiClient, url: URL) {
        self.api = api
        self.url = url
    }
    
    public var properties: PostProperties = .init()
    
    private func expectedValue<T>(_ keyPath: WritableKeyPath<PostProperties, T?>) -> ExpectedValue<T> {
        .init(
            getValue: { self.properties[keyPath: keyPath] },
            provideValue: { try await self.upgrade() })
    }
    
    @ObservationIgnored
    public lazy var actorId: ExpectedValue<ActorIdentifier> = expectedValue(\.actorId)
    
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

    public var vote: (() async throws -> Void)? {
        if let votes = votes.value, let id = id.value {
            return { try await self.vote(existingVotes: votes, existingId: id) }
        }
        return nil
    }
    
    private func vote(existingVotes: VotesModel, existingId: Int) async throws {
        // state fake
        properties.votes = existingVotes.applyScoringOperation(operation: existingVotes.myVote == .upvote ? .none : .upvote)
        
        // do work
        await updateQueue.addItem {
            try await self.api.repository.voteOnPost(id: existingId, score: existingVotes.myVote == .upvote ? .none : .upvote)
        }
    }
    
    internal func upgrade() async throws {
        try await updateQueue.upgrade()
    }
    
    @discardableResult
    public func fetchUpgraded() async throws -> any PostSnapshotProviding {
        var id: Int
        if let existingId = properties.id {
            id = existingId
        } else {
            id = try await api.repository.getPost(url: self.url).post.id
        }
        
        return try await api.repository.getPost(id: id)
    }
}

