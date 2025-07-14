//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-07-14.
//

import Foundation

extension Instance3Snapshot {
    init(from site: LemmyGetSiteResponse) throws(ApiClientError) {
        self.instance = try .init(from: site.siteView)
        self.software = .init(type: .lemmy, version: .init(site.version))
        self.allLanguages = site.allLanguages.compactMap { .init($0) }
        self.allowedLanguageIds = Set(site.discussionLanguages).subtracting([0])
        
        if let blockedUrls = site.blockedUrls {
            var newBlockedUrls: [InstanceUrlBlockRecord] = []
            newBlockedUrls.reserveCapacity(blockedUrls.count)
            for url in blockedUrls {
                try newBlockedUrls.append(.init(from: url))
            }
            self.blockedUrls = newBlockedUrls
        } else {
            self.blockedUrls = nil
        }
    
        var administrators: [Person2Snapshot] = []
        administrators.reserveCapacity(site.admins.count)
        for admin in site.admins {
            try administrators.append(.init(from: admin))
        }
        self.administrators = administrators
    }
}
