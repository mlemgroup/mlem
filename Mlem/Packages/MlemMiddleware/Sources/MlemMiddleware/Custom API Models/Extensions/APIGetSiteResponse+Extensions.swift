//
//  ApiGetSiteResponse+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiGetSiteResponse: ActorIdentifiable, CacheIdentifiable, Identifiable {
    public var cacheId: Int { id }

    public var actorId: ActorIdentifier { siteView.site.actorId }
    public var id: Int { siteView.site.id }
}
