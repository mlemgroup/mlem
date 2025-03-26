//
//  ApiCommentReply+Extensions.swift
//
//
//  Created by Sjmarf on 04/07/2024.
//

import Foundation

extension ApiCommentReply: CacheIdentifiable, Reply1ApiBacker {
    public var cacheId: Int { id }
}
