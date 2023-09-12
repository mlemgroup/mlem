//
//  Feed Root.swift
//  Mlem
//
//  Created by tht7 on 30/06/2023.
//

import SwiftUI

private struct ScrollViewReaderProxy: EnvironmentKey {
    static let defaultValue: ScrollViewProxy? = nil
}

extension EnvironmentValues {
    var scrollViewProxy: ScrollViewProxy? {
        get { self[ScrollViewReaderProxy.self] }
        set { self[ScrollViewReaderProxy.self] = newValue }
    }
}

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
                .environment(\.scrollViewProxy, proxy)
            }
        }
        .environmentObject(navigation)
        .handleLemmyLinkResolution(
            navigationPath: .constant(feedRouter)
        )
        .environmentObject(feedRouter)
        .environmentObject(appState)
        .environment(\.navigationPathWithRoutes, $feedRouter.path)
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
    }
}

struct FeedRootPreview: PreviewProvider {
    static var previews: some View {
        FeedRoot(showLoading: false)
    }
}
