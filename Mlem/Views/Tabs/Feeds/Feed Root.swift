//
//  Feed Root.swift
//  Mlem
//
//  Created by tht7 on 30/06/2023.
//

import SwiftUI

struct FeedRoot: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) var phase
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot

    @StateObject private var feedRouter: NavigationRouter<NavigationRoute> = .init()
    @StateObject private var navigation: Navigation = .init()

    @State var rootDetails: CommunityLinkWithContext?
    
    let showLoading: Bool

    var body: some View {
        /*
         Implementation Note:
         - The conditional content in `detail` column must be inside the `NavigationStack`. To be clear, the root view for `detail` column must be `NavigationStack`, otherwise navigation may break in odd ways. [2023.09]
         - For tab bar navigation (scroll to top) to work, ScrollViewReader must wrap the entire `NavigationSplitView`. Furthermore, the proxy must be passed into the environment on the split view. Attempting to do so on a column view doesn't work. [2023.09]
         */
        ScrollViewReader { proxy in
            NavigationSplitView {
                CommunityListView(selectedCommunity: $rootDetails)
                    .id(appState.currentActiveAccount.id)
            } detail: {
                NavigationStack(path: $feedRouter.path) {
                    if let rootDetails {
                        FeedView(
                            community: rootDetails.community,
                            feedType: rootDetails.feedType,
                            sortType: defaultPostSorting,
                            showLoading: showLoading,
                            rootDetails: $rootDetails
                        )
                        .environmentObject(appState)
                        .tabBarNavigationEnabled(.feeds, navigation)
                        .handleLemmyViews()
                    } else {
                        Text("Please select a community")
                    }
                }
                .id((rootDetails?.id ?? 0) + appState.currentActiveAccount.id)
            }
            .environment(\.scrollViewProxy, proxy)
        }
        .environment(\.navigationPathWithRoutes, $feedRouter.path)
        .environmentObject(navigation)
        .handleLemmyLinkResolution(
            navigationPath: .constant(feedRouter)
        )
        .environmentObject(feedRouter)
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
                
                _ = HandleLemmyLinkResolution(navigationPath: .constant(feedRouter))
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
        .onChange(of: selectedTagHashValue) { newValue in
            if newValue == TabSelection.feeds.hashValue {
                print("switched to Feed tab")
            }
        }
        .onChange(of: selectedNavigationTabHashValue) { newValue in
            if newValue == TabSelection.feeds.hashValue {
                print("re-selected \(TabSelection.feeds) tab")
            }
        }
        .overlay(alignment: .trailing) {
            GroupBox {
                Text("NavigationPath.count: \(feedRouter.path.count)")
            }
        }
    }
}

struct FeedRootPreview: PreviewProvider {
    static var previews: some View {
        FeedRoot(showLoading: false)
    }
}
