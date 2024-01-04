//
//  FeedDecider.swift
//  Mlem
//
//  Created by Sjmarf on 31/12/2023.
//

import SwiftUI

// This is messy I know, but I couldn't work out another way of doing it, thanks to NavigationSplitView's weirdness with NavigationLinks across columns. Sjmarf [2023.12]
struct FeedParentView: View {
    
    let community: CommunityModel?
    let feedType: FeedType?
    
    @Binding var rootDetails: CommunityLinkWithContext?
    @Binding var splitViewColumnVisibility: NavigationSplitViewVisibility
    
    init(
        community: CommunityModel?,
        feedType: FeedType?,
        splitViewColumnVisibility: Binding<NavigationSplitViewVisibility>? = nil,
        rootDetails: Binding<CommunityLinkWithContext?>? = nil
    ) {
        self.community = community
        self.feedType = feedType
        self._splitViewColumnVisibility = splitViewColumnVisibility ?? .constant(.automatic)
        self._rootDetails = rootDetails ?? .constant(nil)
    }
    
    var body: some View {
        Group {
            if let community {
                CommunityView(
                    community: community,
                    splitViewColumnVisibility: $splitViewColumnVisibility,
                    rootDetails: $rootDetails
                )
            } else if let feedType {
                FeedView(feedType: feedType)
            }
        }
    }
}
