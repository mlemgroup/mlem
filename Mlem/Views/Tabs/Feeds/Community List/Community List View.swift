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
    
    @Binding var selectedCommunity: CommunityLinkWithContext?
    
    /// Set to `false` on disappear.
    @State private var appeared: Bool = false
    
    init(selectedCommunity: Binding<CommunityLinkWithContext?>) {
        self._selectedCommunity = selectedCommunity
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            HStack {
                List(selection: $selectedCommunity) {
                    HomepageFeedRowView(.subscribed)
                        .padding(.top, 5)
                        .id("top") // For "scroll to top" sidebar item
                    HomepageFeedRowView(.local)
                    HomepageFeedRowView(.all)
                    HomepageFeedRowView(.saved)
                    
                    ForEach(model.visibleSections) { section in
                        Section(header: headerView(for: section)) {
                            ForEach(model.communities(for: section)) { community in
                                CommuntiyFeedRowView(
                                    community: community,
                                    subscribed: model.isSubscribed(to: community),
                                    communitySubscriptionChanged: model.updateSubscriptionStatus,
                                    navigationContext: .sidebar
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
                .onAppear {
                    appeared = true
                }
                .onDisappear {
                    appeared = false
                }
                
                SectionIndexTitles(proxy: scrollProxy, communitySections: model.allSections())
            }
            .reselectAction(tab: .feeds) {
                guard appeared else {
                    return
                }
                withAnimation {
                    scrollProxy.scrollTo("top", anchor: .bottom)
                }
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
    static var previews: some View {
        Group {
            NavigationStack {
                CommunityListView(selectedCommunity: .constant(nil))
            }
            .previewDisplayName("Populated")
            
            NavigationStack {
                withDependencies {
                    // return no subscriptions...
                    $0.communityRepository.subscriptions = { _ in [] }
                } operation: {
                    CommunityListView(selectedCommunity: .constant(nil))
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
                    CommunityListView(selectedCommunity: .constant(nil))
                }
            }
            .previewDisplayName("Error")
        }
    }
}
