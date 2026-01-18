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
    case comment(Comment2)
    case message(Message2)
    
    var type: ReportType {
        switch self {
        case .post: .post
        case .comment: .comment
        case .message: .message
        }
    }
    
    public var community: Community1? {
        switch self {
        case let .post(post): post.community.value_ as? Community1
        case let .comment(comment): comment.community
        case .message: nil
        }
    }
    
    // TODO: UnifiedCommentModel, UnifiedMessageModel remove this shim
    public var creator: ExpectedValue<any Person1Providing> {
        switch self {
        case let .post(post): post.creator
        case let .comment(comment): .init(
            getValue: { comment.creator },
            provideValue: { fatalError("This should not be called") }
        )
        case let .message(message): .init(
            getValue: { message.creator },
            provideValue: { fatalError("This should not be called") }
        )
        }
    }
    
    @MainActor
    init(from snapshot: ReportTargetSnapshot, api: ApiClient, myPersonId: Int) {
        switch snapshot {
        case let .post(post):
            self = .post(api.caches.post.getModel(api: api, from: .post2(post)))
        case let .comment(comment):
            self = .comment(api.caches.comment2.getModel(api: api, from: comment))
        case let .message(message):
            self = .message(api.caches.message2.getModel(api: api, from: message, myPersonId: myPersonId))
        }
    }
    
    @MainActor
    func update(with snapshot: ReportTargetSnapshot) {
        // TODO: UpdateQueue rework reports to integrate UpdateQueue
        switch (self, snapshot) {
        case (.post, .post):
            break
        case let (.comment(comment), .comment(updatedComment)):
            break
        case let (.message(message), .message(updatedMessage)):
            message.update(with: updatedMessage)
        default:
            assertionFailure()
        }
    }
}

public enum ReportType: Hashable {
    case post, comment, message
    
    var inboxItemType: InboxItemType {
        switch self {
        case .post: .postReport
        case .comment: .commentReport
        case .message: .messageReport
        }
    }
}
