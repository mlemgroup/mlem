//
//  ApiCommunityView+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-19.
//

import Foundation

extension ApiCommunityView: CacheIdentifiable, Identifiable {
    public var cacheId: Int { id }

    public var id: Int { community.id }
}
