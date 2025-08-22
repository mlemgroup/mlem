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
    
    case post(Post2)
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
        case let .post(post): post.community
        case let .comment(comment): comment.community
        case .message: nil
        }
    }
    
    public var creator: Person1 {
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
            self = .post(api.caches.post2.getModel(api: api, from: post))
        case let .comment(comment):
            self = .comment(api.caches.comment2.getModel(api: api, from: comment))
        case let .message(message):
            self = .message(api.caches.message2.getModel(api: api, from: message, myPersonId: myPersonId))
        }
    }
    
    @MainActor
    func update(with snapshot: ReportTargetSnapshot) {
        switch (self, snapshot) {
        case (.post, .post):
            // TODO: UpdateQueue handle report update callbacks through UpdateQueue
            print("noop") // print here to make the compiler happy
        case let (.comment(comment), .comment(updatedComment)):
            comment.update(with: updatedComment)
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
