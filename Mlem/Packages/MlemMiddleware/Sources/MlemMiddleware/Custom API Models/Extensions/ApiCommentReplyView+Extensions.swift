//
//  ApiCommentReplyView+Extensions.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation

extension ApiCommentReplyView: CacheIdentifiable {
    public var cacheId: Int { commentReply.id }
}
