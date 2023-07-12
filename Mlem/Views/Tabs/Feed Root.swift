//
//  Feed Root.swift
//  Mlem
//
//  Created by tht7 on 30/06/2023.
//

import SwiftUI
import AlertToast

struct FeedRoot: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var accountsTracker: SavedAccountTracker
    @Environment(\.scenePhase) var phase

    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed

    @State var navigationPath = NavigationPath()

    @State var rootDetails: CommunityLinkWithContext?
    @State var isShowingToast: Bool = false

    var body: some View {

        NavigationSplitView {
            CommunityListView(selectedCommunity: $rootDetails)
                .id(appState.currentActiveAccount.id)
        } detail: {
            if let rootDetails {
                NavigationStack(path: $navigationPath) {
                    CommunityView(
                        community: rootDetails.community,
                        feedType: rootDetails.feedType
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
        .toast(isPresenting: $appState.isShowingToast, duration: 2) {
            appState.toast ?? AlertToast(type: .regular, title: "Missing toast info")
        }
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
    }
}

struct FeedRootPreview: PreviewProvider {
    static var previews: some View {
        FeedRoot()
    }
}
