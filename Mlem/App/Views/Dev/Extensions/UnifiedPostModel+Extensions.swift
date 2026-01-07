//
//  UnifiedPostModel+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-07.
//

import MlemMiddleware
import SwiftUI

extension UnifiedPostModel {
    var shouldHideInFeed: Bool {
        // TODO: NOW purged
        (creator.value_?.shouldHideInFeed ?? false) || (community.value_?.shouldHideInFeed ?? false) || (hidden.value_ ?? false) // || purged
    }
    
    func taggedTitle(communityContext: (any Community1Providing)?) -> Text {
        let hasTags: Bool = removed
            || deleted
            || pinnedInstance
            || (communityContext != nil && pinnedCommunity)
            || locked
        
        return postTag(active: removed, icon: .lemmy.removed, color: .themedNegative) +
            postTag(active: deleted, icon: .general.delete, color: .themedNegative) +
            postTag(active: pinnedInstance, icon: .lemmy.pinned, color: .themedAdministration) +
            postTag(active: pinnedCommunity && communityContext != nil, icon: .lemmy.pinned, color: .themedModeration) +
            postTag(active: locked, icon: .lemmy.locked, color: .themedLockAccent) +
            Text(verbatim: "\(hasTags ? "  " : "")\(title)")
    }
    
    var imageFallback: MediaView.Fallback {
        switch type {
        case .text: .text
        case let .media(url), let .embedded(url, _):
            url.proxyAwarePathExtension?.isMovieExtension ?? false ? .movie : .image
        case .link: .link
        case .titleOnly: .titleOnly
        }
    }
}
