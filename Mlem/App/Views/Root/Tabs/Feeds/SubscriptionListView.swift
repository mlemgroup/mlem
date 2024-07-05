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
    @AppStorage("subscriptions.instanceLocation")
    private var savedInstanceLocation: InstanceLocation = UIDevice.isPad ? .bottom : .trailing
    
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
    
    var selection: Binding<NavigationPage?> {
        .init(get: {
            if UIDevice.isPad {
                noDetail ? nil : navigation.root
            } else {
                navigation.path.first
            }
        }, set: { newValue in
            Task { @MainActor in
                if UIDevice.isPad {
                    if let newValue {
                        navigation.root = newValue
                        noDetail = false
                    } else {
                        noDetail = true
                    }
                } else {
                    navigation.popToRoot()
                    if let newValue {
                        navigation.push(newValue)
                    }
                }
            }
        })
    }
    
    @ViewBuilder
    var content: some View {
        let subscriptions = (appState.firstSession as? UserSession)?.subscriptions
        let sections = subscriptions?.visibleSections(sort: sort) ?? []
        
        ScrollViewReader { proxy in
            List {
                ForEach(sections) { section in
                    Section(section.label) {
                        ForEach(section.communities) { (community: Community2) in
                            NavigationLink(.community(community)) {
                                HStack(spacing: 15) {
                                    buttonLabel(community, section: section)
                                }
                            }
                            .contextMenu(actions: community.menuActions(feedback: [.toast]).children)
                            .swipeActions(edge: .trailing) {
                                Button("Unsubscribe", systemImage: "xmark") {
                                    community.toggleSubscribe(feedback: [.toast])
                                }
                                .labelStyle(.iconOnly)
                                .tint(.red)
                            }
                            .padding(.trailing, sectionIndicesShown ? 5 : 0)
                        }
                    }
                    .id(section.label)
                }
                .scrollTargetLayout()
            }
            .overlay(alignment: .trailing) {
                if sectionIndicesShown {
                    SectionIndexTitles(
                        proxy: proxy,
                        sections: [.init(label: "Favorites", systemImage: "star.fill")]
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
    
    @ViewBuilder
    private func buttonLabel(
        _ community: Community2,
        section: SubscriptionListSection
    ) -> some View {
        switch instanceLocation(section: section) {
        case .trailing:
            AvatarView(community)
                .frame(height: 28)
            (
                Text(community.name)
                    + Text("@\(community.host ?? "unknown")")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            )
            .lineLimit(1)
        case .bottom:
            AvatarView(community)
                .frame(height: 36)
            VStack(alignment: .leading, spacing: 0) {
                Text(community.name)
                    .lineLimit(1)
                Text("@\(community.host ?? "")")
                    .foregroundStyle(.secondary)
                    .font(.footnote)
            }
        case .disabled:
            AvatarView(community)
                .frame(height: 28)
            Text(community.name)
                .lineLimit(1)
        }
    }
    
    var sectionIndicesShown: Bool {
        !UIDevice.isPad && sort == .alphabetical
    }
    
    private func instanceLocation(section: SubscriptionListSection) -> InstanceLocation {
        switch sort {
        case .alphabetical:
            savedInstanceLocation
        case .instance:
            section.label == "Other" ? .trailing : .disabled
        }
    }
}

private enum SubscriptionListSort: String, CaseIterable {
    case alphabetical
    case instance
    
    var label: String { rawValue.capitalized }
    
    var systemImage: String {
        switch self {
        case .alphabetical:
            "textformat"
        case .instance:
            "at"
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
            sections.append(.init(label: "Favorites", systemImage: Icons.favoriteFill, communities: favorites))
        }
        switch sort {
        case .alphabetical:
            for section in alphabeticSections.sorted(by: { $0.key ?? "~" < $1.key ?? "~" }) {
                sections.append(.init(label: section.key ?? "#", communities: section.value))
            }
        case .instance:
            for section in instanceSections.sorted(by: { $0.key ?? "~" < $1.key ?? "~" }) {
                sections.append(.init(label: section.key ?? "Other", communities: section.value))
            }
        }
        
        return sections
    }
}
