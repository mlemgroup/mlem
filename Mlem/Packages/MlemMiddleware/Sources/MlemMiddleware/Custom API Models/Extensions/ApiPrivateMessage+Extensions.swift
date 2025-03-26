//
//  ApiPrivateMessage+Extensions.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

extension ApiPrivateMessage: CacheIdentifiable {
    public var cacheId: Int { id }
}
