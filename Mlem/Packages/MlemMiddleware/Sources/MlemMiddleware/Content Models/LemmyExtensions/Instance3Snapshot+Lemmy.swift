//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Instance3Snapshot {
    init(from site: LemmyGetSiteResponse) throws(ApiClientError) {
        let blockedUrls: [InstanceUrlBlockRecord]?
        if let blockedUrls_ = site.blockedUrls {
            var newBlockedUrls: [InstanceUrlBlockRecord] = []
            newBlockedUrls.reserveCapacity(blockedUrls_.count)
            for url in blockedUrls_ {
                try newBlockedUrls.append(.init(from: url))
            }
            blockedUrls = newBlockedUrls
        } else {
            blockedUrls = nil
        }
    
        var administrators: [Person2Snapshot] = []
        administrators.reserveCapacity(site.admins.count)
        for admin in site.admins {
            try administrators.append(.init(from: admin))
        }

        try self.init(
            instance: .init(from: site.siteView),
            allLanguages: site.allLanguages.compactMap { .init($0) },
            software: .init(type: .lemmy, version: .init(site.version)),
            allowedLanguageIds: Set(site.discussionLanguages).subtracting([0]),
            blockedUrls: blockedUrls,
            administrators: administrators
        )
    }
}
