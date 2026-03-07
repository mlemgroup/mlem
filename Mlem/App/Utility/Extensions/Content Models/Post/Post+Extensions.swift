//
//  Post+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-07.
//

import MlemMiddleware
import SwiftUI

extension Post {
    func shouldShowLoadingSymbol(for barConfiguration: PostBarConfiguration? = nil) -> Bool {
        if lockedPending, !(barConfiguration?.all.contains(.action(.lock)) ?? false) {
            return true
        }
        if pinnedCommunityPending, !(barConfiguration?.all.contains(.action(.pin)) ?? false) {
            return true
        }
        if pinnedInstancePending, !(barConfiguration?.all.contains(.action(.pin)) ?? false) {
            return true
        }
        if nsfwPending {
            return true
        }
        return false
    }
    
    var shouldHideInFeed: Bool {
        (creator.value_?.shouldHideInFeed ?? false) || (community.value_?.shouldHideInFeed ?? false) || (hidden.value_ ?? false) || purged
    }
    
    func taggedTitle(communityContext: Community?) -> Text {
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
        case .poll: .poll
        case .titleOnly: .titleOnly
        }
    }
}
