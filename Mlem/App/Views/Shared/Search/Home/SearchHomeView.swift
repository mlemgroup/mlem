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
        VStack(
            alignment: useWideLayout ? .leading : .center,
            spacing: 20
        ) {
            subheadingView("Recently Searched")
                .frame(maxWidth: .infinity, alignment: .leading)

            if let session = appState.firstSession as? UserSession,
                let visitHistory = session.visitHistory {
                RecentSearchListView(visitHistory: visitHistory)
            }

            if appState.firstAccount.accountType != .guest {
                subheadingView("Visit Again")
                    .frame(maxWidth: .infinity, alignment: .leading)
                topRow
            }
            
            subheadingView("Browse")
                .frame(maxWidth: .infinity, alignment: .leading)
            browseList
                .padding(.top, 15)

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
    func subheadingView(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.title)
            .fontWeight(.semibold)
            .padding(.bottom, -4)
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
        HStack {
            subheadingView("Events")
                .padding(.trailing, 5)
            if !useWideLayout {
                Spacer()
            }
            eventsMenuView
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 15)
        AdaptableSearchHomeListView(isGrid: useWideLayout) {
            ForEach(events) { 
                EventRowView(event: $0)
            }
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

            if !useWideLayout { Spacer() }

            NavigationLink("Users", icon: .lemmy.person, destination: .topPeople)
                .tint(.themedPersonAccent)

            if !useWideLayout { Spacer() }

            NavigationLink("Instances", icon: .lemmy.instance, destination: .topInstances)
                .tint(.themedInstanceAccent)
        }
        .labelStyle(SearchHomeCategoryLabelStyle())
        .buttonStyle(.empty)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    var browseGrid: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 16) {
            GridButton(title: "Top Communities", color: .themedCommunityAccent)
            GridButton(title: "Trending Communities", color: .themedColorfulAccent(0))
            GridButton(title: "Users", color: .themedPersonAccent)
            GridButton(title: "Instances", color: .themedInstanceAccent)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, -4)
    }
}

private struct GridButton: View {
    @Environment(\.palette) var palette
    
    let title: LocalizedStringResource
    let color: ThemedColor
    
    var body: some View {
        ZStack {
            Text(title)
                .foregroundStyle(.themedContrastingLabel)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
        }
        .aspectRatio(5 / 3, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .background(color.resolve(with: palette).gradient)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal, 4)
        .onTapGesture {}
    }
}
