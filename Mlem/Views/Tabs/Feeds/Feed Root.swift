//
//  Feed Root.swift
//  Mlem
//
//  Created by tht7 on 30/06/2023.
//

import SwiftUI

struct FeedRoot: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker
    @EnvironmentObject var feedSortTypeTracker: FeedSortTypeTracker
    @Environment(\.scenePhase) var phase
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed

    @State var navigationPath = NavigationPath()

    @State var rootDetails: CommunityLinkWithContext?
    
    let showLoading: Bool

    var body: some View {

        NavigationSplitView {
            CommunityListView(selectedCommunity: $rootDetails)
                .id(appState.currentActiveAccount.id)
        } detail: {
            if let rootDetails {
                NavigationStack(path: $navigationPath) {
                    FeedView(
                        community: rootDetails.community,
                        feedType: rootDetails.feedType,
                        sortType: rootDetails.community != nil
                        ? feedSortTypeTracker.getSortType(for: rootDetails.community!)
                        : feedSortTypeTracker.getSortType(for: rootDetails.feedType),
                        showLoading: showLoading
                    )
                    .environmentObject(appState)
                    .handleLemmyViews()
                }
                .id(rootDetails.id + appState.currentActiveAccount.id)
            } else {
                Text("Please select a community") 
            }
        }
        .handleLemmyLinkResolution(
            navigationPath: $navigationPath
        )
        .environment(\.navigationPath, $navigationPath)
        .environmentObject(appState)
        .environmentObject(accountsTracker)
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
                
                _ = HandleLemmyLinkResolution(appState: _appState,
                                          navigationPath: $navigationPath
                )
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
