//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-06-14.
//

import Foundation

public extension Instance3Snapshot {
    init(pieFed: PieFedGetSiteResponse, lemmy: PieFedLemmyCompatibleSiteResponse) throws(ApiClientError) {
        // In addition to having their own site request, PieFed also impersonates
        // Lemmy's site request at "api/v3/site". We also use that response here,
        // because the response contains some data that is missing from PieFed's
        // own site request.
        
        // The source code for this is here (function name: `lemmy_site_data`)
        // https://codeberg.org/rimu/pyfedi/src/commit/75c48f6d22ec831e05bc54852f514caf34a60d0a/app/activitypub/util.py
        
        guard let allLanguages = pieFed.site.allLanguages else {
            throw ApiClientError.responseMissingRequiredData("PieFedSite allLanguages")
        }
        
        var administrators: [Person2Snapshot] = []
        administrators.reserveCapacity(pieFed.admins.count)
        for admin in pieFed.admins {
            try administrators.append(.init(from: admin))
        }

        try self.init(
            instance: .init(pieFed: pieFed.site, lemmy: lemmy.siteView),
            allLanguages: allLanguages.compactMap { .init($0) },
            software: .init(type: .pieFed, version: .init(pieFed.version)),
            allowedLanguageIds: .init(0 ... allLanguages.count - 1),
            blockedUrls: [],
            administrators: administrators
        )
    }
}
