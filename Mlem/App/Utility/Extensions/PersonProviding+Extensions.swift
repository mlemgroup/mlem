//
//  PersonProviding+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-12-22.
//

import MlemMiddleware
import Foundation

extension Person4Providing {
    var moderatedCommunityIds: Set<URL> {
        .init(moderatedCommunities.map { $0.actorId })
    }
}
