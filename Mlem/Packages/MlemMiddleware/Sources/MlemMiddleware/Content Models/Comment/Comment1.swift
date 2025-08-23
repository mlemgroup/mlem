//
//  Comment1.swift
//
//
//  Created by Sjmarf on 24/06/2024.
//

import Foundation
import Observation

@Observable
public final class Comment1: Comment1Providing {
    public var updateQueue: CommentUpdateQueue = .init()
    
    public static let tierNumber: Int = 1
    public var api: ApiClient
    public var comment1: Comment1 { self }
    
    public let actorId: ActorIdentifier
    public let id: Int
    public let parentCommentIds: [Int]
    public let creatorId: Int
    public let postId: Int
    public var created: Date

    public var content: String
    public var updated: Date?
    public var distinguished: Bool
    public var languageId: Int
    
    public var purged: Bool = false
    
    public var deleted: Bool
    
    public var removed: Bool
    public var removedPending: Bool = false
    
    init(
        api: ApiClient,
        actorId: ActorIdentifier,
        id: Int,
        content: String,
        removed: Bool,
        created: Date,
        updated: Date?,
        deleted: Bool,
        creatorId: Int,
        postId: Int,
        parentCommentIds: [Int],
        distinguished: Bool,
        languageId: Int
    ) {
        self.api = api
        self.actorId = actorId
        self.id = id
        self.content = content
        self.removed = removed
        self.created = created
        self.updated = updated
        self.deleted = deleted
        self.creatorId = creatorId
        self.postId = postId
        self.parentCommentIds = parentCommentIds
        self.distinguished = distinguished
        self.languageId = languageId
        
        Task {
            await updateQueue.setParent(self)
        }
    }
}
