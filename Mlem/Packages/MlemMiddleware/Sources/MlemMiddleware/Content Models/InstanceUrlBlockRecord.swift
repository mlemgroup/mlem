//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-13.
//

import Foundation

public struct InstanceUrlBlockRecord: Hashable {
    let id: Int
    let created: Date
    let updated: Date?
    let url: URL
    
    public init(from blocklist: LemmyLocalSiteUrlBlocklist) throws(ApiClientError) {
        self.id = blocklist.id
        
        if let published = blocklist.publishedAt ?? blocklist.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyLocalSiteUrlBlocklist published")
        }
        
        self.updated = blocklist.updatedAt ?? blocklist.updated
        
        guard let url = URL(string: blocklist.url) else {
            throw .responseMissingRequiredData("LemmyLocalSiteUrlBlocklist Invalid URL")
        }
        self.url = url
    }
}
