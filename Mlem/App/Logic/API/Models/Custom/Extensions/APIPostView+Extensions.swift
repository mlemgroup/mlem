//
//  ApiPostView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiPostView: ActorIdentifiable, CacheIdentifiable, Identifiable {
    var cacheId: Int { actorId.hashValue }

    var actorId: URL { post.apId }
    var id: Int { post.id }
}
