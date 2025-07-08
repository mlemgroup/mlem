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
    
    public init?(from blocklist: LemmyLocalSiteUrlBlocklist) {
        self.id = blocklist.id
        self.created = blocklist.published
        self.updated = blocklist.updated
        
        guard let url = URL(string: blocklist.url) else {
            return nil
        }
        self.url = url
    }
}
