//
//  Comment.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-19.
//

import Observation
import Foundation

@Observable
public class Comment: UnifiedModelProviding {
    public typealias Properties = CommentProperties
    
    public var api: ApiClient
    private let properties: CommentProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<Comment> = .init(parent: self, properties: properties)
    
    // MARK: Custom Properties
    // Mlem-specific properties that are not reflected in the API
    
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
