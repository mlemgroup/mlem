//
//  ApiSiteView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiSiteView: CacheIdentifiable, ActorIdentifiable, Identifiable {
    var cacheId: Int { actorId.hashValue }
    
    var actorId: URL { site.actorId }
    var id: Int { site.id }
}
