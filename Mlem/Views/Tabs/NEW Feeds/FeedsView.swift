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
                List(selection: $selectedFeed) {
                    ForEach([NewFeedType.all, NewFeedType.local, NewFeedType.subscribed, NewFeedType.saved]) { feedType in
                        FeedRowView(feedType: feedType)
                    }
                    
                    ForEach(communityListModel.visibleSections) { section in
                        Section(header: headerView(for: section)) {
                            ForEach(communityListModel.communities(for: section)) { community in
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
                    Text("This is the all feed!")
                case .local:
                    Text("This is the local feed!")
                case .subscribed:
                    Text("This is the subscribed feed!")
                case .saved:
                    Text("This is the saved feed!")
                case .none:
                    Text("Please select a feed")
                }
            }
        }
    }
    
    private func headerView(for section: CommunitySection) -> some View {
        HStack {
            Text(section.inlineHeaderLabel!)
                .accessibilityLabel(section.accessibilityLabel)
            Spacer()
        }
        .id(section.viewId)
    }
}
