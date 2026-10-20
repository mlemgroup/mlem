//
//  SearchHomeView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-08-14.
//

import ComponentViews
import FediverseEvents
import Icons
import SwiftUI
import Theming

struct SearchHomeView: View {
    @Environment(\.navigation) var navigation
    @Environment(\.palette) var palette

    @Environment(AppState.self) var appState
    @Environment(EventsTracker.self) var eventsTracker
    
    @Setting(\.events_showEvents) var showEvents

    @State private var width: CGFloat = 0

    var body: some View {
        sectionsView {
            if let session = appState.firstSession as? UserSession,
                let visitHistory = session.visitHistory {
                Section("Recently Searched") {
                    RecentSearchListView(visitHistory: visitHistory)
                }
            }

            if appState.firstAccount.accountType != .guest {
                Section("Visit Again") {
                    topRow
                }
            }
            
            Section("Browse") {
                browseList
            }

            if let events = eventsTracker.events, !events.isEmpty, showEvents {
                eventsView(events)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
    }

    var useWideLayout: Bool {
        width > 500
    }

    @ViewBuilder
    var topRow: some View {
        AdaptableSearchHomeListView(isGrid: useWideLayout) {
            NavigationLink("Saved", icon: .lemmy.savedFeed, destination: .savedFeed)
                .tint(.themedSavedFeed)
            NavigationLink("Upvoted", icon: .lemmy.upvoted, destination: .upvotedFeed)
                .tint(.themedUpvote)
        }
    }

    @ViewBuilder
    func eventsView(_ events: [Event]) -> some View {
        Section {
            AdaptableSearchHomeListView(isGrid: useWideLayout) {
                ForEach(events) { 
                    EventRowView(event: $0)
                }
            }
        } header: {
            Text("Events")
            if !useWideLayout {
                Spacer()
            }
            eventsMenuView
        }
    }

    @ViewBuilder
    var eventsMenuView: some View {
        Menu("More", icon: .general.menu) {
            Button("Turn Off Events", icon: .general.hide, role: .destructive) {
                showEvents = false
            }
        }
        .foregroundStyle(.secondary)
        .font(.title)
        .labelStyle(.iconOnly)
        .padding(.trailing, 10)
        .padding(.bottom, -6)
    }
    
    @ViewBuilder
    var browseList: some View {
        HStack(alignment: .center, spacing: useWideLayout ? 30 : 0) {
            NavigationLink("Communities", icon: .lemmy.community, destination: .topCommunities)
                .tint(.themedCommunityAccent)

            NavigationLink("Users", icon: .lemmy.person, destination: .topPeople)
                .tint(.themedPersonAccent)
                .frame(maxWidth: useWideLayout ? nil : .infinity)

            NavigationLink("Instances", icon: .lemmy.instance, destination: .topInstances)
                .tint(.themedInstanceAccent)
        }
        .labelStyle(SearchHomeCategoryLabelStyle())
        .buttonStyle(.empty)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    @ViewBuilder
    func sectionsView(@ViewBuilder _ content: () -> some View) -> some View {
        VStack(
            alignment: useWideLayout ? .leading : .center,
            spacing: 30
        ) {
            ForEach(sections: content()) { section in
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 15) {
                        section.header
                            .font(.title)
                            .fontWeight(.semibold)
                    }
                    section
                        .content
                }
            }
        }
    }
}
