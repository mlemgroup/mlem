//
//  ApiPersonMentionView+Extensions.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

extension ApiPersonMentionView: CacheIdentifiable {
    public var cacheId: Int { personMention.id }
}
