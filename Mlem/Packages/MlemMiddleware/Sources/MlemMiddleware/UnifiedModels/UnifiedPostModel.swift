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
    
    var id: Int?
    var title: String?
    var votes: VotesModel?
    var linkUrl: URL??
    
    @MainActor
    public mutating func update(with snapshot: any PostSnapshotProviding) {
        Logger.dev.info("Updating...")
        if let snapshot1 = snapshot as? Post1Snapshot {
            Logger.dev.info("Got title \(snapshot1.title)")
            self.id = snapshot1.id
            self.title = snapshot1.title
            self.linkUrl = snapshot1.linkUrl
        }
        if let snapshot2 = snapshot as? Post2Snapshot {
            self.votes = snapshot2.votes
        }
        
        if let snapshot3 = snapshot as? Post3Snapshot {
            self.id = snapshot3.post.post.id
            self.title = snapshot3.post.post.title
            self.linkUrl = snapshot3.post.post.linkUrl
            self.votes = snapshot3.post.votes
        }
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
    public lazy var id: ExpectedValue<Int> = expectedValue(\.id)

    @ObservationIgnored
    public lazy var title: ExpectedValue<String> = expectedValue(\.title)
  
    @ObservationIgnored
    public lazy var votes: ExpectedValue<VotesModel> = expectedValue(\.votes)
    
    @ObservationIgnored
    public lazy var linkUrl: ExpectedValue<URL?> = expectedValue(\.linkUrl)

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
