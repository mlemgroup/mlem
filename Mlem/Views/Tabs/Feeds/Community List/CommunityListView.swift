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
    
    @StateObject private var model: CommunityListModel = .init()

    let headerBodySpacing: CGFloat = 4

    // MARK: - Body
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                Spacer()
                    .frame(height: 10)
                VStack(spacing: 30) {
                    VStack(spacing: headerBodySpacing) {
                        headerText("Feeds")
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                FeedButtonView(
                                    feedType: .subscribed,
                                    title: "Subscribed",
                                    iconName: "newspaper.fill",
                                    iconColor: .red
                                )
                                FeedButtonView(
                                    feedType: .local,
                                    title: "Local",
                                    iconName: "house.fill",
                                    iconColor: .orange
                                )
                            }
                            HStack(spacing: 12) {
                                FeedButtonView(
                                    feedType: .all,
                                    title: "All",
                                    iconName: "circle.hexagongrid.fill",
                                    iconColor: .blue
                                )
                                FeedButtonView(
                                    feedType: .subscribed,
                                    title: "Saved",
                                    iconName: "bookmark.fill",
                                    iconColor: .green
                                )
                            }
                        }
                    }
                    
                    ForEach(model.visibleSections) { section in
                        VStack(spacing: headerBodySpacing) {
                            headerView(for: section)
                            VStack(spacing: 0) {
                                let communities = model.communities(for: section)
                                if let last = communities.last {
                                    ForEach(communities) { community in
                                        CommuntiyFeedRowView(
                                            community: community,
                                            subscribed: model.isSubscribed(to: community),
                                            communitySubscriptionChanged: model.updateSubscriptionStatus
                                        )
                                        if community != last {
                                            Divider()
                                        }
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    
                    Spacer()
                        .frame(height: 30)
                }
                .padding(.horizontal, 20)
                .fancyTabScrollCompatible()
                .navigationTitle("Communities")
                .navigationBarColor()
                .listStyle(.insetGrouped)
                .scrollIndicators(.hidden)
            }
            .overlay(alignment: .trailing) {
                SectionIndexTitles(proxy: scrollProxy, communitySections: model.allSections())
            }
            .background(Color(.systemGroupedBackground))
            .refreshable {
                await model.load()
            }
            .onAppear {
                Task(priority: .high) {
                    await model.load()
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    // MARK: - Subviews
    
    private func headerView(for section: CommunitySection) -> some View {
        HStack {
            headerText(section.inlineHeaderLabel!)
            Spacer()
        }
        .accessibilityLabel(section.accessibilityLabel)
        .id(section.viewId)
    }
    
    private func headerText(_ text: String) -> some View {
        HStack {
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .padding(.leading, 10)
            Spacer()
        }
    }
}

// MARK: - Previews

struct CommunityListViewPreview: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationStack {
                CommunityListView()
            }
            .previewDisplayName("Populated")
            
            NavigationStack {
                withDependencies {
                    // return no subscriptions...
                    $0.communityRepository.subscriptions = { _ in [] }
                } operation: {
                    CommunityListView()
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
                    CommunityListView()
                }
            }
            .previewDisplayName("Error")
        }
    }
}
