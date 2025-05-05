//
//  ApiPostView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiPostView: CacheIdentifiable, Identifiable {
    public var cacheId: Int { id }
    public var id: Int { post.id }
}
