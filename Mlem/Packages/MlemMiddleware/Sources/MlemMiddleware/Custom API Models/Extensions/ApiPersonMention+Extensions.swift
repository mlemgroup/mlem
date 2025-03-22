//
//  ApiPersonMention+Extensions.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

extension ApiPersonMention: CacheIdentifiable, Reply1ApiBacker {
    public var cacheId: Int { id }
}
