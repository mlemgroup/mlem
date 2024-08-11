//
//  PrefetchingConfiguration+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import Nuke
import MlemMiddleware

extension PrefetchingConfiguration {
    static func forPostSize(_ postSize: PostSize) -> Self {
        let imageSize: ImageResolution
        if let size = postSize.imageSize {
            imageSize = .limited(size)
        } else {
            imageSize = .unlimited
        }
        return .init(
            prefetcher: .init(pipeline: .shared, destination: .memoryCache, maxConcurrentRequestCount: 40),
            imageSize: imageSize,
            avatarSize: postSize.avatarSize
        )
    }
}
