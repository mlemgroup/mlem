//
//  SubscriptionListView.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import MlemMiddleware
import SwiftUI

struct SubscriptionListView: View {
    @Environment(AppState.self) private var appState
    @Environment(NavigationLayer.self) private var navigation
    @Environment(TabReselectTracker.self) var tabReselectTracker
    @Environment(Palette.self) var palette
    
    @Setting(\.subscriptionSort) private var sort
    
    @State var noDetail: Bool = false
    
    var feedOptions: [FeedSelection] {
        appState.firstAccount is UserAccount ? FeedSelection.allCases : FeedSelection.guestCases
    }
    
    var body: some View {
        content
            .listStyle(.sidebar)
            .navigationTitle("Feeds")
    }
    
    var detailDisplayed: Bool {
        if UIDevice.isPad {
            noDetail ? false : navigation.path.isEmpty
        } else {
            navigation.path.isEmpty
        }
    }

    @ViewBuilder
    var content: some View {
        let sections = subscriptions?.visibleSections(sort: sort) ?? []
        
        ScrollViewReader { proxy in
            // Form {
            ScrollView {
                VStack(spacing: 0) {
                    SectionMimicView {
                        ForEach(Array(feedOptions.enumerated()), id: \.element.hashValue) { index, feedOption in
                            SubscriptionListNavigationButton(.feeds(feedOption)) {
                                HStack(alignment: .center, spacing: 15) {
                                    FeedIconView(
                                        feedDescription: feedOption.description,
                                        size: appState.firstSession is GuestSession ? 36 : 28
                                    )
                                    
                                    VStack(spacing: 0) {
                                        if index > 0 { Divider() }
                                        
                                        HStack(spacing: 0) {
                                            VStack(alignment: .leading) {
                                                Text(feedOption.description.label)
                                                if appState.firstSession is GuestSession {
                                                    Text(feedOption.description.subtitle)
                                                        .font(.footnote)
                                                        .foregroundStyle(palette.secondary)
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: Icons.forward)
                                                .font(.footnote)
                                                .fontWeight(.bold)
                                                .foregroundStyle(palette.tertiary)
                                        }
                                        .padding(.vertical, 12)
                                        .padding(.trailing, 16)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .contentShape(.rect)
                                .padding(.leading, 16)
                            }
                        }
                    }
                    
                    //                if AccountsTracker.main.isEmpty {
                    //                    Section {
                    //                        signedOutInfoView
                    //                            .listRowBackground(Color.clear)
                    //                    }
                    //                }
                    //
                    //                ForEach(sections) { section in
                    //                    SubscriptionListSectionView(section: section, sectionIndicesShown: sectionIndicesShown)
                    //                        .id(section.label)
                    //                }
                    //                .scrollTargetLayout()
                }
            }
            .foregroundStyle(palette.primary)
            .overlay(alignment: .trailing) {
                if sectionIndicesShown {
                    SectionIndexTitles(
                        proxy: proxy,
                        sections: [.init(label: String(localized: "Favorites"), systemImage: "star.fill")]
                            + "ABCDEFGHIJKLMNOPQRSTUVWYZ#".map { .init(label: String($0)) }
                    )
                }
            }
            .toolbar {
                if !(subscriptions?.communities.isEmpty ?? true) {
                    Picker("Sort", selection: $sort) {
                        ForEach(SubscriptionListSort.allCases, id: \.self) { item in
                            Label(item.label, systemImage: item.systemImage)
                        }
                    }
                }
            }
            .onChange(of: tabReselectTracker.flag) {
                // normal reselect tracker does not work here thanks to NavigationSplitView, so we need to implement a custom one
                if detailDisplayed, tabReselectTracker.flag {
                    tabReselectTracker.reset()
                    withAnimation {
                        proxy.scrollTo(sections.first?.label)
                    }
                }
            }
            .scrollIndicators(sectionIndicesShown ? .hidden : .visible)
            .refreshable {
                do {
                    try await subscriptions?.refresh()
                } catch {
                    handleError(error)
                }
            }
            .background(palette.groupedBackground)
        }
    }
    
    @ViewBuilder
    var signedOutInfoView: some View {
        VStack {
            Image(systemName: "list.bullet")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .foregroundStyle(palette.tertiary)
                .padding(.bottom, 5)
            Text("Your subscriptions live here.")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Log in or sign up to view your subscriptions.")
            HStack {
                Button {
                    navigation.openSheet(.logIn(.pickInstance))
                } label: {
                    Text("Log In")
                        .frame(minWidth: 80)
                }
                Button {
                    navigation.openSheet(.signUp())
                } label: {
                    Text("Sign Up")
                        .frame(minWidth: 80)
                }
            }
            .tint(palette.secondary)
            .buttonStyle(.bordered)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .foregroundColor(palette.secondary)
    }
    
    var subscriptions: SubscriptionList? {
        (appState.firstSession as? UserSession)?.subscriptions
    }
    
    var sectionIndicesShown: Bool {
        !UIDevice.isPad && sort == .alphabetical && (subscriptions?.communities.count ?? 0) > 10
    }
}

private struct SectionMimicView<Content: View>: View {
    @Environment(Palette.self) var palette
    
    var content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .background(palette.background.clipShape(RoundedRectangle(cornerRadius: 10)))
        .padding(15)
    }
}

private struct SubscriptionListSectionView: View {
    let section: SubscriptionListSection
    let sectionIndicesShown: Bool
    
    var body: some View {
        Section(section.label) {
            ForEach(section.communities) { (community: Community2) in
                SubscriptionListItemView(
                    community: community,
                    section: section,
                    sectionIndicesShown: sectionIndicesShown
                )
            }
        }
    }
}

enum SubscriptionListSort: String, CaseIterable, Codable {
    case alphabetical
    case instance
    
    var label: String {
        switch self {
        case .alphabetical: "Alphabetical"
        case .instance: "Instance"
        }
    }
    
    var systemImage: String {
        switch self {
        case .alphabetical: "textformat"
        case .instance: "at"
        }
    }
}

struct SubscriptionListSection: Identifiable {
    let label: String
    var systemImage: String?
    let communities: [Community2]
    
    var id: String { label }
}

private extension SubscriptionList {
    func visibleSections(sort: SubscriptionListSort) -> [SubscriptionListSection] {
        var sections: [SubscriptionListSection] = .init()
        if !favorites.isEmpty {
            sections.append(.init(label: String(localized: "Favorites"), systemImage: Icons.favoriteFill, communities: favorites))
        }
        switch sort {
        case .alphabetical:
            for section in alphabeticSections.sorted(by: { $0.key ?? "~" < $1.key ?? "~" }) {
                sections.append(.init(label: section.key ?? "#", communities: section.value))
            }
        case .instance:
            for section in instanceSections.sorted(by: { $0.key ?? "~" < $1.key ?? "~" }) {
                sections.append(.init(label: section.key ?? String(localized: "Other"), communities: section.value))
            }
        }
        
        return sections
    }
}
