//
//  ReportTarget.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

public enum ReportTarget {
    enum Case {
        case post, comment, message
    }
    
    var `case`: Case {
        switch self {
        case .post: .post
        case .comment: .comment
        case .message: .message
        }
    }
    
    case post(Post)
    case comment(Comment)
    case message(Message)
    
    var type: ReportType {
        switch self {
        case .post: .post
        case .comment: .comment
        case .message: .message
        }
    }
    
    public var community: Community? {
        switch self {
        case let .post(post): post.community.value_
        case let .comment(comment): comment.community.value_
        case .message: nil
        }
    }
    
    public var creator: ExpectedValue<Person> {
        switch self {
        case let .post(post): post.creator
        case let .comment(comment): comment.creator
        case let .message(message): message.creator
        }
    }
    
    @MainActor
    init(from snapshot: ReportTargetSnapshot, api: ApiClient, myPersonId: Int) {
        switch snapshot {
        case let .post(post):
            self = .post(api.caches.post.getModel(api: api, from: .post2(post)))
        case let .comment(comment):
            self = .comment(api.caches.comment.getModel(api: api, from: .comment2(comment)))
        case let .message(message):
            self = .message(api.caches.message.getModel(api: api, from: .message2(message), myPersonId: myPersonId))
        }
    }
    
    func attemptDirectUpdate(with snapshot: ReportTargetSnapshot) async {
        switch (self, snapshot) {
        case let (.post(post), .post(snapshot)):
            await post.updateQueue.attemptDirectUpdate(with: .init(api: post.api, snapshot: .post2(snapshot)))
        case let (.comment(comment), .comment(snapshot)):
            await comment.updateQueue.attemptDirectUpdate(with: .init(api: comment.api, snapshot: .comment2(snapshot)))
        case let (.message(message), .message(snapshot)):
            await message.updateQueue.attemptDirectUpdate(
                with: .init(api: message.api, snapshot: .message2(snapshot), isOwnMessage: message.isOwnMessage)
            )
        default:
            assertionFailure()
        }
    }
}

public enum ReportType: Hashable {
    case post, comment, message
}
