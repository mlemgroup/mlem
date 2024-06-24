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
    
    @AppStorage("subscriptions.sort") private var sort: SubscriptionListSort = .alphabetical
    @AppStorage("subscriptions.instanceLocation")
    private var savedInstanceLocation: InstanceLocation = UIDevice.isPad ? .bottom : .trailing
    
    @State var noDetail: Bool = false
    
    var body: some View {
        Group {
            if UIDevice.isPad {
                content
                    .listStyle(.sidebar)
            } else {
                content
                    .listStyle(.plain)
            }
        }
        .navigationTitle("Subscription List")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var selection: Binding<NavigationPage?> {
        .init(get: { noDetail ? nil : navigation.root }, set: { newValue in
            if let newValue {
                navigation.root = newValue
                noDetail = false
            } else {
                noDetail = true
            }
        })
    }
    
    @ViewBuilder
    var content: some View {
        let sections = (appState.firstSession as? UserSession)?.subscriptions?.visibleSections(sort: sort) ?? []
        
        ScrollViewReader { proxy in
            List(selection: selection) {
                ForEach(sections) { section in
                    Section(section.label) {
                        ForEach(section.communities) { (community: Community2) in
                            NavigationLink(.community(community)) {
                                HStack(spacing: 15) {
                                    buttonLabel(community, section: section)
                                }
                            }
                            .contextMenu(actions: community.menuActions.children)
                        }
                    }
                    .id(section.label)
                }
                .scrollTargetLayout()
            }
            .toolbar {
                Picker("Sort", selection: $sort) {
                    ForEach(SubscriptionListSort.allCases, id: \.self) { item in
                        Label(item.label, systemImage: item.systemImage)
                    }
                }
            }
            .onReselectTab {
                withAnimation {
                    proxy.scrollTo(sections.first?.label)
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

private struct SubscriptionListSection: Identifiable {
    let label: String
    let communities: [Community2]
    
    var id: String { label }
}

private extension SubscriptionList {
    func visibleSections(sort: SubscriptionListSort) -> [SubscriptionListSection] {
        var sections: [SubscriptionListSection] = .init()
        if !favorites.isEmpty {
            sections.append(.init(label: "Favorites", communities: favorites))
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
