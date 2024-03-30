//
//  ApiSite+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiSite: CacheIdentifiable, ActorIdentifiable, Identifiable {
    var cacheId: Int { actorId.hashValue }
}
