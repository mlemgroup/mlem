//
//  Feed Root.swift
//  Mlem
//
//  Created by tht7 on 30/06/2023.
//

import Dependencies
import SwiftUI

struct FeedRoot: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) var phase
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed

    @StateObject private var feedTabNavigation: AnyNavigationPath<AppRoute> = .init()
    @StateObject private var navigation: Navigation = .init()
    
    @State var rootDetails: CommunityLinkWithContext?
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    var body: some View {
        /*
         Implementation Note:
         - The conditional content in `detail` column must be inside the `NavigationStack`. To be clear, the root view for `detail` column must be `NavigationStack`, otherwise navigation may break in odd ways. [2023.09]
         - For tab bar navigation (scroll to top) to work, ScrollViewReader must wrap the entire `NavigationSplitView`. Furthermore, the proxy must be passed into the environment on the split view. Attempting to do so on a column view doesn't work. [2023.09]
         */
        ScrollViewReader { scrollProxy in
            NavigationSplitView(columnVisibility: $columnVisibility) {
                // CommunityListView(selectedCommunity: $rootDetails)
                CommunityListView()
                    .navigationDestination(for: FeedSelection.self) { feedType in
                        NavigationStack(path: $feedTabNavigation.path) {
                            switch feedType {
                            case .saved:
                                SavedFeedView()
                            case .subscribed:
                                FeedView(
                                    community: nil, // rootDetails.community,
                                    feedType: .subscribed, // rootDetails.feedType,
                                    rootDetails: $rootDetails,
                                    splitViewColumnVisibility: $columnVisibility
                                )
                                .environmentObject(appState)
                                .environmentObject(feedTabNavigation)
                                .tabBarNavigationEnabled(.feeds, navigation)
                                .handleLemmyViews()
                            case .local:
                                FeedView(
                                    community: nil, // rootDetails.community,
                                    feedType: .local, // rootDetails.feedType,
                                    rootDetails: $rootDetails,
                                    splitViewColumnVisibility: $columnVisibility
                                )
                                .environmentObject(appState)
                                .environmentObject(feedTabNavigation)
                                .tabBarNavigationEnabled(.feeds, navigation)
                                .handleLemmyViews()
                            case .all:
                                FeedView(
                                    community: nil, // rootDetails.community,
                                    feedType: .all, // rootDetails.feedType,
                                    rootDetails: $rootDetails,
                                    splitViewColumnVisibility: $columnVisibility
                                )
                                .environmentObject(appState)
                                .environmentObject(feedTabNavigation)
                                .tabBarNavigationEnabled(.feeds, navigation)
                                .handleLemmyViews()
                            case let .community(communityLink):
                                FeedView(
                                    community: communityLink.community,
                                    feedType: .subscribed,
                                    rootDetails: $rootDetails,
                                    splitViewColumnVisibility: $columnVisibility
                                )
                                .environmentObject(appState)
                                .environmentObject(feedTabNavigation)
                                .tabBarNavigationEnabled(.feeds, navigation)
                                .handleLemmyViews()
                            }
                        }
                    }
            } detail: {
                Text("Please select a community")
//                NavigationStack(path: $feedTabNavigation.path) {
//                    if let rootDetails {
//                        if rootDetails.feedType == .saved {
//                            SavedFeedView()
//                        } else {
//                            FeedView(
//                                community: rootDetails.community,
//                                feedType: rootDetails.feedType,
//                                rootDetails: $rootDetails,
//                                splitViewColumnVisibility: $columnVisibility
//                            )
//                            .environmentObject(appState)
//                            .environmentObject(feedTabNavigation)
//                            .tabBarNavigationEnabled(.feeds, navigation)
//                            .handleLemmyViews()
//                        }
//                    } else {
//                        Text("Please select a community")
//                    }
//                }
//                .id(rootDetails?.id ?? 0)
            }
            .environment(\.scrollViewProxy, scrollProxy)
        }
        .handleLemmyLinkResolution(
            navigationPath: .constant(feedTabNavigation)
        )
        .environment(\.navigationPathWithRoutes, $feedTabNavigation.path)
        .environment(\.navigation, navigation)
        .environmentObject(feedTabNavigation)
        .environmentObject(appState)
        .onAppear {
            if rootDetails == nil || shortcutItemToProcess != nil {
                let feedType = FeedType(rawValue:
                    shortcutItemToProcess?.type ??
                        "nothing to see here"
                ) ?? defaultFeed
                rootDetails = CommunityLinkWithContext(community: nil, feedType: feedType)
                shortcutItemToProcess = nil
            }
        }
        .onOpenURL { url in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if rootDetails == nil {
                    rootDetails = CommunityLinkWithContext(community: nil, feedType: defaultFeed)
                }
                
                _ = HandleLemmyLinkResolution(navigationPath: .constant(feedTabNavigation))
                    .didReceiveURL(url)
            }
        }
        .onChange(of: phase) { newPhase in
            if newPhase == .active {
                if let shortcutItem = FeedType(rawValue:
                    shortcutItemToProcess?.type ??
                        "nothing to see here"
                ) {
                    rootDetails = CommunityLinkWithContext(community: nil, feedType: shortcutItem)

                    shortcutItemToProcess = nil
                }
            }
        }
    }
}

struct FeedRootPreview: PreviewProvider {
    static var previews: some View {
        FeedRoot()
    }
}
