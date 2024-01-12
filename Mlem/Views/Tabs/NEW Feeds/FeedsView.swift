//
//  FeedsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-07.
//

import Foundation
import SwiftUI

struct FeedsView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var appState: AppState
    
    @State private var selectedFeed: NewFeedType?
    
    @StateObject private var communityListModel: CommunityListModel = .init()
    
    var body: some View {
        content
            .onAppear {
                Task(priority: .high) {
                    await communityListModel.load()
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active, let shortcutItem = NewFeedType.fromShortcut(shortcut: shortcutItemToProcess?.type) {
                    selectedFeed = shortcutItem
                }
            }
    }
    
    var content: some View {
        ScrollViewReader { _ in
            NavigationSplitView {
                // Note on navigation: nesting List(selection: $selectedFeed) inside a NavigationSplitView here automagically sets up navigation so that nav links inside this block update selectedFeed, which is then handled by the switch in the detail. This can also be achieved by defining .navigationDestinations on the List; those will then propagate to the detail when selected, but due to the amount of manual navigation stuff we're doing this approach seems less troublesome [Eric 2023.01.11]
                List(selection: $selectedFeed) {
                    ForEach([NewFeedType.all, NewFeedType.local, NewFeedType.subscribed, NewFeedType.saved]) { feedType in
                        // These are automagically turned into NavigationLinks
                        FeedRowView(feedType: feedType)
                    }
                    
                    ForEach(communityListModel.visibleSections) { section in
                        Section(header: communitySectionHeaderView(for: section)) {
                            ForEach(communityListModel.communities(for: section)) { community in
                                // These are not automagically turned into NavigationLinks, so we do it manually
                                NavigationLink(value: NewFeedType.all) {
                                    CommunityFeedRowView(
                                        community: community,
                                        subscribed: communityListModel.isSubscribed(to: community),
                                        communitySubscriptionChanged: communityListModel.updateSubscriptionStatus,
                                        navigationContext: .sidebar
                                    )
                                }
                            }
                        }
                    }
                }
            } detail: {
                switch selectedFeed {
                case .all:
                    AggregateFeedView(feedType: .all)
                case .local:
                    AggregateFeedView(feedType: .local)
                case .subscribed:
                    AggregateFeedView(feedType: .subscribed)
                case .saved:
                    AggregateFeedView(feedType: .saved)
                case .none:
                    Text("Please select a feed")
                }
            }
        }
    }
    
    private func communitySectionHeaderView(for section: CommunitySection) -> some View {
        HStack {
            Text(section.inlineHeaderLabel!)
                .accessibilityLabel(section.accessibilityLabel)
            Spacer()
        }
        .id(section.viewId)
    }
}