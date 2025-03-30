//
//  ApiPersonMentionView+Extensions.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

extension ApiPersonMentionView: CacheIdentifiable, Reply2ApiBacker {
    public var cacheId: Int { personMention.id }
    public var reply: any Reply1ApiBacker { personMention }
    
    public var resolvedSaved: Bool { saved }
}
