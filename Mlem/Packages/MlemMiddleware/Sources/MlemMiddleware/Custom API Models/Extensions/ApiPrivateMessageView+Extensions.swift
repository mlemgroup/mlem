//
//  ApiPrivateMessageView+Extensions.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation

extension ApiPrivateMessageView: CacheIdentifiable {
    public var cacheId: Int { privateMessage.id }
}
