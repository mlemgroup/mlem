//
//  FeedsView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-07.
//

import Dependencies
import Foundation
import SwiftUI

struct FeedsView: View {
    @Dependency(\.siteInformation) var siteInformation
    @AppStorage("defaultFeed") var defaultFeed: DefaultFeedType = .subscribed
    
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.tabReselectionHashValue) var tabReselectionHashValue
    
    @EnvironmentObject var appState: AppState
    
    @State private var selectedFeed: PostFeedType?
    @State var appeared: Bool = false // tracks whether this is the view's first appearance
    
    @StateObject private var communityListModel: CommunityListModel = .init()
    
    @StateObject private var feedTabNavigation: AnyNavigationPath<AppRoute> = .init()
    @StateObject private var navigation: Navigation = .init()
    
    @Namespace var scrollToTop
    
    var body: some View {
        content
            .onAppear {
                // on first appearance, immediately navigate to defaultFeed
                if !appeared {
                    appeared = true
                    selectedFeed = defaultFeed.toFeedType
                }
                
                Task(priority: .high) {
                    await communityListModel.load()
                }
            }
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active, let shortcutItem = PostFeedType.fromShortcutString(shortcut: shortcutItemToProcess?.type) {
                    selectedFeed = shortcutItem
                }
            }
            .handleLemmyLinkResolution(navigationPath: .constant(feedTabNavigation))
    }
    
    var content: some View {
        ScrollViewReader { scrollProxy in
            NavigationSplitView {
                // Note that NavigationLinks in here update selectedFeed and are handled by the detail switch, not the general navigation handler
                ZStack(alignment: .trailing) {
                    List(selection: $selectedFeed) {
                        ForEach(siteInformation.feeds) { feedType in
                            NavigationLink(value: feedType) {
                                FeedRowView(feedType: feedType)
                            }
                        }
                        .id(scrollToTop) // using this instead of ScrollToView because ScrollToView renders as an empty list item
                        .padding(.trailing, 10)
                        
                        communitySections
                            .padding(.trailing, 10)
                    }
                    .scrollIndicators(.hidden)
                    .navigationTitle("Feeds")
                    .listStyle(PlainListStyle())
                    .refreshable {
                        await Task {
                            await communityListModel.load()
                        }.value
                    }
                    .fancyTabScrollCompatible()
                    
                    SectionIndexTitles(proxy: scrollProxy, communitySections: communityListModel.sections)
                }
                .onChange(of: tabReselectionHashValue) { newValue in
                    // due to NavigationSplitView weirdness, the normal .hoistNavigation doesn't work here, so we do it manually
                    // only scroll to top if the selected feed is nil (i.e., detail view is not presented)
                    // this has the side effect of disabling tap tab to scroll to top on iPad, which I'm going to say is a feature not a bug [Eric 2024.01.31]
                    if newValue == TabSelection.feeds.hashValue, selectedFeed == nil {
                        withAnimation {
                            scrollProxy.scrollTo(scrollToTop)
                        }
                    }
                }
            } detail: {
                NavigationStack(path: $feedTabNavigation.path) {
                    ScrollViewReader { scrollProxy in
                        navStackView
                            .environmentObject(feedTabNavigation)
                            .environment(\.scrollViewProxy, scrollProxy)
                            .tabBarNavigationEnabled(.feeds, navigation)
                            .handleLemmyViews()
                    }
                }
            }
            .environment(\.navigationPathWithRoutes, $feedTabNavigation.path)
            .environment(\.navigation, navigation)
        }
    }
    
    @ViewBuilder
    var communitySections: some View {
        ForEach(communityListModel.sections) { section in
            Section(header: communitySectionHeaderView(for: section)) {
                ForEach(section.communities) { community in
                    NavigationLink(value: PostFeedType.community(.init(from: community, subscribed: true))) {
                        CommunityFeedRowView(
                            community: community,
                            subscribed: communityListModel.isSubscribed(to: community),
                            communitySubscriptionChanged: updateSubscriptionStatus, // communityListModel.updateSubscriptionStatus,
                            navigationContext: .sidebar
                        )
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private var navStackView: some View {
        switch selectedFeed {
        case .all, .local, .subscribed, .moderated, .saved:
            AggregateFeedView(selectedFeed: $selectedFeed)
        case let .community(communityModel):
            CommunityFeedView(communityModel: communityModel)
                .id(communityModel.uid) // explicit id forces redraw on change of community model
        case .none:
            Text("Please select a feed")
        }
    }
    
    private func updateSubscriptionStatus(_ community: APICommunity, _ status: Bool) {
        Task {
            await communityListModel.updateSubscriptionStatus(for: community, subscribed: status)
        }
    }
    
    @ViewBuilder
    private func communitySectionHeaderView(for section: CommunityListSection) -> some View {
        if let header = section.inlineHeaderLabel {
            HStack {
                Text(header)
                    .accessibilityLabel(section.accessibilityLabel)
                Spacer()
            }
            .id(section.viewId)
        }
    }
}
