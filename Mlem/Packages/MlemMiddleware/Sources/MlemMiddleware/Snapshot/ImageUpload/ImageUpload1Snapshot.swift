//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-05.
//

import Foundation

public struct ImageUpload1Snapshot: CacheIdentifiable {
    public let url: URL
    
    public let deleteToken: ImageDeleteToken
    
    public init(
        url: URL,
        deleteToken: ImageDeleteToken
    ) {
        self.url = url
        self.deleteToken = deleteToken
    }
    
    public var cacheId: Int {
        url.hashValue
    }
}
