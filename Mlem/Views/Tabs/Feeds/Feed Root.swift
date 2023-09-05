//
//  Feed Root.swift
//  Mlem
//
//  Created by tht7 on 30/06/2023.
//

import SwiftUI

class NavigationRouter: ObservableObject {
    @Published var navigationPath = NavigationPath()
    
    init(navigationPath: NavigationPath = NavigationPath()) {
        print("INIT", navigationPath.count)
        self.navigationPath = navigationPath
    }
}

struct FeedRoot: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.scenePhase) var phase
    @Environment(\.tabSelectionHashValue) private var selectedTagHashValue
    @Environment(\.tabNavigationSelectionHashValue) private var selectedNavigationTabHashValue
    
    @AppStorage("defaultFeed") var defaultFeed: FeedType = .subscribed
    @AppStorage("defaultPostSorting") var defaultPostSorting: PostSortType = .hot
    
    let showLoading: Bool
    
    @State var rootDetails: CommunityLinkWithContext? = .init(community: nil, feedType: .subscribed)

    var body: some View {
        NavigationSplitView {
            CommunityListView()
                .id(appState.currentActiveAccount.id)
        } detail: {
            if let rootDetails = rootDetails {
                FeedDetailRoot(destination: rootDetails)
            } else {
                Text("Please select a community")
            }
        }
        // .environmentObject(router)
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
