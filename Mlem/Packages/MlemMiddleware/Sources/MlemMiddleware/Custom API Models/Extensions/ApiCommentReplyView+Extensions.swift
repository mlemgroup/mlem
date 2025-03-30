//
//  ApiCommentReplyView+Extensions.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation

extension ApiCommentReplyView: CacheIdentifiable, Reply2ApiBacker {
    public var cacheId: Int { commentReply.id }
    public var reply: any Reply1ApiBacker { commentReply }
    
    public var resolvedSaved: Bool { saved ?? false }
}
