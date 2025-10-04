//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-05.
//

import Foundation

public struct ImageUpload1Snapshot: CacheIdentifiable {
    public let url: URL
    
    public let alias: String?
    public let deleteToken: String?
    
    public init(
        url: URL,
        alias: String?,
        deleteToken: String?
    ) {
        self.url = url
        self.alias = alias
        self.deleteToken = deleteToken
    }
    
    public var cacheId: Int {
        url.hashValue
    }
}
