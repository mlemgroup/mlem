//
//  RecentSearchListView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-10-18.
//

import SwiftUI

struct RecentSearchListView: View {
    @Environment(NavigationLayer.self) var navigation

    let visitHistory: VisitHistory

    typealias Item = VisitHistory.Item

    var body: some View {
        let items = visitHistory.all(withContext: .search)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 16)], spacing: 16) {
            ForEach(items, id: \.viewId) { item in
                itemView(item)
                    .popupAnchor()
            }
        }
        .buttonStyle(RecentSearchItemButtonStyle())
    }

    @ViewBuilder
    func itemView(_ item: Item) -> some View {
        switch item {
        case let .community(community):
            Button {
                navigation.push(.community(community, visitContext: .other))
            } label: {
                CommunityListRowBody(community, complications: [.type])
            }
            .contextMenu(community: community)
        case let .person(person):
            Button {
                navigation.push(.person(person, visitContext: .other))
            } label: {
                PersonListRowBody(person, complications: [.type])
            }
            .contextMenu(person: person)
        case let .instance(instance):
            Button {
                navigation.push(.instanceStub(instance.instanceStub, visitContext: .other))
            } label: {
                InstanceListRowBody(instance, complications: [.type])
            }
            .contextMenu(instance: instance)
        }
    }
}

private struct RecentSearchItemButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .contentShape(.rect(cornerRadius: 16))
            .padding(.vertical, 6)
            .background(.themedSecondaryGroupedBackground, in: .rect(cornerRadius: 16))
            .paletteBorder(cornerRadius: 16)
    }
}
