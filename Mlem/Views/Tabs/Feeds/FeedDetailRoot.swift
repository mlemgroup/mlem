//
//  FeedDetailRoot.swift
//  Mlem
//
//  Created by Sjmarf on 04/09/2023.
//

import SwiftUI

struct FeedDetailRoot: View {
    
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    
    @State var router = NavigationRouter()
    
    @State var rootDetails: CommunityLinkWithContext
    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            FeedView(community: rootDetails.community, feedType: rootDetails.feedType, sortType: defaultPostSorting)
                .handleLemmyViews()
                .id(UUID())
                .handleLemmyLinkResolution(
                    navigationPath: $router.navigationPath
                )
        }
        .id(UUID())
        .onAppear {
            print("APPEAR")
        }
        .environmentObject(router)
        
        .handleLemmyLinkResolution(
            navigationPath: $router.navigationPath
        )
        .onOpenURL { url in
            DispatchQueue.main.asyncAfter(deadline: .now()) {                
                _ = HandleLemmyLinkResolution(navigationPath: $router.navigationPath)
                    .didReceiveURL(url)
            }
        }
    }
}
