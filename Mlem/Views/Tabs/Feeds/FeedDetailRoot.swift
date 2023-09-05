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
    
    @State var router: NavigationRouter = NavigationRouter()
    
    @State var destination: CommunityLinkWithContext
    
//    init(destination: CommunityLinkWithContext) {
//        let router = NavigationRouter()
//        _router = State(wrappedValue: router)
//        _rootDetails = State(wrappedValue: destination)
//    }
//    
    var body: some View {
        NavigationStack(path: $router.navigationPath) {
//            Text("Hello world")
            FeedView(community: destination.community, feedType: destination.feedType, sortType: defaultPostSorting)
                .id(UUID())
                .handleLemmyViews()
                .handleLemmyLinkResolution(
                    navigationPath: $router.navigationPath
                )
        }
        .handleLemmyLinkResolution(
            navigationPath: $router.navigationPath
        )
       
//        .handleLemmyLinkResolution(
//            navigationPath: $router.navigationPath
//        )
        .id(UUID())
        .environmentObject(router)
        .handleLemmyViews()
//        .onOpenURL { url in
//            DispatchQueue.main.asyncAfter(deadline: .now()) {                
//                _ = HandleLemmyLinkResolution(navigationPath: $router.navigationPath)
//                    .didReceiveURL(url)
//            }
//        }
    }
}
