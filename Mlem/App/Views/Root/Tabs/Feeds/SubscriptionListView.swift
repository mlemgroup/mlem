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
    
    @AppStorage("subscriptions.sort") private var sort: SubscriptionListSort = .alphabetical
    
    @State var noDetail: Bool = false
    
    var body: some View {
        MultiplatformView(phone: {
            content
                .listStyle(.plain)
        }, pad: {
            content
                .listStyle(.sidebar)
        })
        .navigationTitle("Feeds")
        .navigationBarTitleDisplayMode(.inline)
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
        let subscriptions = (appState.firstSession as? UserSession)?.subscriptions
        let sections = subscriptions?.visibleSections(sort: sort) ?? []
        
        ScrollViewReader { proxy in
            List {
                Section {
                    NavigationLink(.feeds) {
                        Text("Feeds")
                    }
                }
                
                ForEach(sections) { section in
                    SubscriptionListSectionView(section: section, sectionIndicesShown: sectionIndicesShown)
                        .id(section.label)
                }
                .scrollTargetLayout()
            }
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
                Picker("Sort", selection: $sort) {
                    ForEach(SubscriptionListSort.allCases, id: \.self) { item in
                        Label(item.label, systemImage: item.systemImage)
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
        }
    }
    
    var sectionIndicesShown: Bool {
        !UIDevice.isPad && sort == .alphabetical
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

enum SubscriptionListSort: String, CaseIterable {
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
