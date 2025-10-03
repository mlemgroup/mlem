//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-14.
//

import Foundation

public extension Instance1Snapshot {
    init(from site: PieFedSite) throws(ApiClientError) {
        self.init(
            actorId: site.actorId,
            // This is kinda dodgy
            id: site.actorId.hashValue,
            instanceId: site.actorId.hashValue,
            created: Date(timeIntervalSince1970: 0),
            updated: nil,
            publicKey: "",
            displayName: site.name,
            description: site.sidebarMd ?? site.sidebar,
            shortDescription: site.description,
            avatar: site.icon,
            banner: nil,
            lastRefresh: Date(timeIntervalSince1970: 0),
            contentWarning: nil
        )
    }
}
