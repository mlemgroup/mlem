//
//  Community List View.swift
//  Mlem
//
//  Created by Jake Shirey on 17.06.2023.
//

import Dependencies
import SwiftUI

struct CommunitySection: Identifiable {
    let id = UUID()
    let viewId: String
    let sidebarEntry: any SidebarEntry
    let inlineHeaderLabel: String?
    let accessibilityLabel: String
}

struct CommunityListView: View {
    
    @StateObject private var model: CommunityListModel
    
    @Binding var selectedCommunity: CommunityLinkWithContext?

    init(selectedCommunity: Binding<CommunityLinkWithContext?>, account: SavedAccount) {
        self._selectedCommunity = selectedCommunity
        self._model = StateObject(wrappedValue: CommunityListModel(account: account))
    }

    // MARK: - Body
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            HStack {
                List(selection: $selectedCommunity) {
                    HomepageFeedRowView(
                        feedType: .subscribed,
                        iconName: AppConstants.subscribedFeedSymbolNameFill,
                        iconColor: .red,
                        description: "Subscribed communities from all servers"
                    )
                    .id("top") // For "scroll to top" sidebar item
                    HomepageFeedRowView(
                        feedType: .local,
                        iconName: AppConstants.localFeedSymbolNameFill,
                        iconColor: .green,
                        description: "Local communities from your server"
                    )
                    HomepageFeedRowView(
                        feedType: .all,
                        iconName: AppConstants.federatedFeedSymbolNameFill,
                        iconColor: .blue,
                        description: "All communities that federate with your server"
                    )
                    
                        ForEach(model.visibleSections) { section in
                            Section(header: headerView(for: section)) {
                                ForEach(model.communities(for: section)) { community in
                                    CommuntiyFeedRowView(
                                        community: community,
                                        subscribed: model.isSubscribed(to: community),
                                        communitySubscriptionChanged: model.updateSubscriptionStatus
                                    )
                                }
                            }
                        }
                    }
                .fancyTabScrollCompatible()
                .navigationTitle("Communities")
                .navigationBarColor()
                .listStyle(PlainListStyle())
                .scrollIndicators(.hidden)

                SectionIndexTitles(proxy: scrollProxy, communitySections: model.allSections())
            }
        }
        .refreshable {
            await model.load()
        }
        .onAppear {
            Task(priority: .high) {
                await model.load()
            }
        }
    }
    
    // MARK: - Subviews
    
    private func headerView(for section: CommunitySection) -> some View {
        HStack {
            Text(section.inlineHeaderLabel!)
                .accessibilityLabel(section.accessibilityLabel)
            Spacer()
        }
        .id(section.viewId)
    }
}

// MARK: - Previews

struct CommunityListViewPreview: PreviewProvider {
    static var appState = AppState(
        defaultAccount: .mock(),
        selectedAccount: .constant(nil)
    )
    
    static var previews: some View {
        Group {
            NavigationStack {
                CommunityListView(
                    selectedCommunity: .constant(nil),
                    account: .mock()
                )
                .environmentObject(
                    FavoriteCommunitiesTracker()
                )
                .environmentObject(appState)
            }
            .previewDisplayName("Populated")
            
            NavigationStack {
                withDependencies {
                    // return no subscriptions...
                    $0.communityRepository.subscriptions = { _ in [] }
                } operation: {
                    CommunityListView(
                        selectedCommunity: .constant(nil),
                        account: .mock()
                    )
                    .environmentObject(
                        FavoriteCommunitiesTracker()
                    )
                    .environmentObject(appState)
                }
            }
            .previewDisplayName("Empty")
            
            NavigationStack {
                withDependencies {
                    // return an error when calling subscriptions
                    $0.communityRepository.subscriptions = { _ in
                        throw APIClientError.response(.init(error: "Borked"), nil)
                    }
                } operation: {
                    CommunityListView(
                        selectedCommunity: .constant(nil),
                        account: .mock()
                    )
                    .environmentObject(
                        FavoriteCommunitiesTracker()
                    )
                    .environmentObject(appState)
                }
            }
            .previewDisplayName("Error")
        }
    }
}
