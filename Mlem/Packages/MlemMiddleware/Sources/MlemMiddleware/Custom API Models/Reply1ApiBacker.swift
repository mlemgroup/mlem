//
//  Reply1ApiBacker.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

/// This protocol is conformed to be ``ApiCommentReply`` and ``ApiPersonMention``.
public protocol Reply1ApiBacker: CacheIdentifiable, Identifiable {
    var id: Int { get }
    var recipientId: Int { get }
    var commentId: Int { get }
    var read: Bool { get }
    var published: Date { get }
}

public extension Reply1ApiBacker {
    var cacheId: Int { id }
}
