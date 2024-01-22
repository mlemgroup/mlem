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
    
    @StateObject private var feedTabNavigation: AnyNavigationPath<AppRoute> = .init()
    @StateObject private var navigation: Navigation = .init()
    
    var body: some View {
        content
            // .navigationTitle("Communities")
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
        ScrollViewReader { scrollProxy in
            NavigationSplitView {
                // Note that NavigationLinks in here update selectedFeed and are handled by the detail switch, not the general navigation handler
                ZStack(alignment: .trailing) {
                    List(selection: $selectedFeed) {
                        ForEach([NewFeedType.all, NewFeedType.local, NewFeedType.subscribed, NewFeedType.saved]) { feedType in
                            NavigationLink(value: feedType) {
                                FeedRowView(feedType: feedType)
                            }
                        }
                        .padding(.trailing, 10)
                        
                        ForEach(communityListModel.visibleSections) { section in
                            Section(header: communitySectionHeaderView(for: section)) {
                                ForEach(communityListModel.communities(for: section)) { community in
                                    NavigationLink(value: NewFeedType.community(.init(from: community, subscribed: true))) {
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
                        .padding(.trailing, 10)
                    }
                    .scrollIndicators(.hidden)
                    .navigationTitle("Communities")
                    .listStyle(PlainListStyle())
                    
                    SectionIndexTitles(proxy: scrollProxy, communitySections: communityListModel.allSections())
                }
            } detail: {
                NavigationStack(path: $feedTabNavigation.path) {
                    Group {
                        switch selectedFeed {
                        case .all:
                            AggregateFeedView(feedType: .all)
                        case .local:
                            AggregateFeedView(feedType: .local)
                        case .subscribed:
                            AggregateFeedView(feedType: .subscribed)
                        case .saved:
                            SavedFeedView()
                        case let .community(communityModel):
                            CommunityFeedView(communityModel: communityModel)
                        case .none:
                            Text("Please select a feed")
                        }
                    }
                    .handleLemmyViews()
                }
            }
        }
    }
    
    private func communitySectionHeaderView(for section: CommunityListSection) -> some View {
        HStack {
            Text(section.inlineHeaderLabel!)
                .accessibilityLabel(section.accessibilityLabel)
            Spacer()
        }
        .id(section.viewId)
    }
}
