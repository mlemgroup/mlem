//
//  PrefetchingConfiguration+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import MlemMiddleware
import Nuke

extension PrefetchingConfiguration {
    static func forPostSize(_ postSize: PostSize) -> Self {
        .init(
            prefetcher: .init(pipeline: .shared, destination: .memoryCache, maxConcurrentRequestCount: 40),
            imageSize: .limited(Constants.main.feedImageResolution),
            avatarSize: postSize.avatarSize
        )
    }
}
