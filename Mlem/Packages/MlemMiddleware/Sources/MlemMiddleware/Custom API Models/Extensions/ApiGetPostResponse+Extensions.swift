//
//  ApiGetPostResponse+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 25/09/2024.
//

import Foundation

extension ApiGetPostResponse: ActorIdentifiable, CacheIdentifiable, Identifiable {
    public var cacheId: Int { id }

    public var actorId: ActorIdentifier { postView.post.actorId }
    public var id: Int { postView.post.id }
}
