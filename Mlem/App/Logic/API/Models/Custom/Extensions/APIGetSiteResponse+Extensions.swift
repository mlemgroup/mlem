//
//  ApiGetSiteResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiGetSiteResponse: ActorIdentifiable, CacheIdentifiable, Identifiable {
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }

    var actorId: URL { siteView.site.actorId }
    var id: Int { siteView.site.id }
}
