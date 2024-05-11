//
//  SubscriptionListView.swift
//  Mlem
//
//  Created by Sjmarf on 11/05/2024.
//

import MlemMiddleware
import SwiftUI

private struct SubscriptionListSection: Identifiable {
    let label: String
    let communities: [Community2]
    
    var id: String { label }
}

private extension SubscriptionList {
    var visibleSections: [SubscriptionListSection] {
        var sections: [SubscriptionListSection] = .init()
        if !favorites.isEmpty {
            sections.append(.init(label: "Favorites", communities: favorites))
        }
        for section in alphabeticSections.sorted(by: { $0.key ?? "~" < $1.key ?? "~" }) {
            sections.append(.init(label: section.key ?? "#", communities: section.value))
        }
        return sections
    }
}

struct SubscriptionListView: View {
    @Environment(AppState.self) var appState
    
    var body: some View {
        List {
            ForEach(appState.firstAccount.subscriptions?.visibleSections ?? .init()) { section in
                Section(section.label) {
                    ForEach(section.communities) { community in
                        HStack {
                            Text(community.name)
                            Spacer()
                            let action = community.favoriteAction
                            Button(action: action.callback ?? {}) {
                                Image(systemName: action.menuIcon)
                                    .foregroundStyle(action.isOn ? action.color : .primary)
                            }
                            .buttonStyle(EmptyButtonStyle())
                            .disabled(action.callback == nil)
                            .opacity(action.callback == nil ? 0.5 : 1)
                        }
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle("Subscription List")
        .navigationBarTitleDisplayMode(.inline)
    }
}
