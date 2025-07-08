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
    
    public var cacheId: Int {
        url.hashValue
    }
    
    public init(from file: LemmyPictrsFile, baseUrl: URL) {
        self.url = baseUrl.appending(path: "pictrs/image/\(file.file)")
        self.alias = file.file
        self.deleteToken = file.deleteToken
    }
}
