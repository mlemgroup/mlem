//
//  Community List View.swift
//  Mlem
//
//  Created by Jake Shirey on 17.06.2023.
//

import Dependencies
import SwiftUI

struct NewCommunityListView: View {
    @StateObject private var model: CommunityListModel = .init()
    
    @Binding var selectedFeedType: NewFeedType?
    
    /// Set to `false` on disappear.
    @State private var appeared: Bool = false
    
    init(selectedCommunity: Binding<NewFeedType?>) {
        self._selectedFeedType = selectedCommunity
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            HStack {
                List(selection: $selectedFeedType) {
                    HomepageFeedRowView(.subscribed)
                        .padding(.top, 5)
                        .id("top") // For "scroll to top" sidebar item
                    HomepageFeedRowView(.local)
                    HomepageFeedRowView(.all)
                    
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
