//
//  ReportTarget.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-16.
//

import Foundation

public enum ReportTarget {
    enum Case {
        case post, comment, message, legacyPost, legacyComment
    }
    
    var `case`: Case {
        switch self {
        case .post: .post
        case .comment: .comment
        case .message: .message
        case .legacyPost: .legacyPost
        case .legacyComment: .legacyComment
        }
    }
    
    /// All post reports use this case on 0.19.4 and above.
    case post(Post2)
    /// All comment reports use this case on 0.19.4 and above.
    case comment(Comment2)
    /// All messages reports use this case regardless of version.
    case message(Message2)
    
    // TODO: 0.19.3 deprecation - remove the below two cases and associated code.
    
    // `ApiPostReportView` is a superset of `ApiPostView` from 0.19.4 onwards, allowing
    // us to create a `Post2` (as seen above). However, prior to 0.19.4 this was not the
    // case - only *some* of the necessary properties are included.
    
    // For simplicity I've opted to only store `Post1` on those older versions rather than creating
    // a new intermediate `Post` tier. This solution means losing access to certain information
    // (e.g. vote and save status) but saves significant headache so I think it's easier to just
    // not display vote status on pre-0.19.4 versions.
    
    /// All post reports use this case on 0.19.3 and below.
    case legacyPost(Post1, community: Community1, creator: Person1)
    /// All comment reports use this case on 0.19.3 and below.
    case legacyComment(Comment1, community: Community1, creator: Person1)
    
    var type: ReportType {
        switch self {
        case .post, .legacyPost: .post
        case .comment, .legacyComment: .comment
        case .message: .message
        }
    }
    
    public var community: Community1? {
        switch self {
        case let .legacyPost(_, community, _): community
        case let .post(post): post.community
        case let .legacyComment(_, community, _): community
        case let .comment(comment): comment.community
        case .message: nil
        }
    }
    
    public var creator: Person1 {
        switch self {
        case let .legacyPost(_, _, creator): creator
        case let .post(post): post.creator
        case let .legacyComment(_, _, creator): creator
        case let .comment(comment): comment.creator
        case let .message(message): message.creator
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
