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
    
    var body: some View {
        VStack(spacing: 20) {
            if appState.firstAccount.accountType != .guest {
                subheadingView("Visit Again")
                topRow
            }
            
            subheadingView("Browse")
            browseList
                .padding(.top, 15)

            if let events = eventsTracker.events, !events.isEmpty {
                eventsView(events)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    @ViewBuilder
    func subheadingView(_ text: LocalizedStringResource) -> some View {
        Text(text)
            .font(.title)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, -4)
    }
    
    @ViewBuilder
    var topRow: some View {
        SearchHomeListView {
            NavigationLink("Saved", icon: .lemmy.savedFeed, destination: .savedFeed)
                .tint(.themedSavedFeed)
            NavigationLink("Upvoted", icon: .lemmy.upvoted, destination: .upvotedFeed)
                .tint(.themedUpvote)
        }
        .buttonStyle(.chevron)
    }

    @ViewBuilder
    func eventsView(_ events: [Event]) -> some View {
        subheadingView("Events")
            .padding(.top, 15)
        SearchHomeListView {
            ForEach(events) { 
                EventRowView(event: $0)
            }
        }
    }
    
    @ViewBuilder
    var browseList: some View {
        HStack(alignment: .center, spacing: UIDevice.isPad ? 30 : 0) {
            NavigationLink("Communities", icon: .lemmy.community, destination: .topCommunities)
                .tint(.themedCommunityAccent)

            if !UIDevice.isPad { Spacer() }

            NavigationLink("Users", icon: .lemmy.person, destination: .topPeople)
                .tint(.themedPersonAccent)

            if !UIDevice.isPad { Spacer() }

            NavigationLink("Instances", icon: .lemmy.instance, destination: .topInstances)
                .tint(.themedColorfulAccent(1))
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
            GridButton(title: "Instances", color: .themedColorfulAccent(1))
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
