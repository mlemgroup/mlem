//
//  ApiGetPostResponse+Extensions.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 25/09/2024.
//

import Foundation

extension ApiGetPostResponse: CacheIdentifiable, Identifiable {
    public var cacheId: Int { id }

    public var id: Int { postView.post.id }
}
