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
    @State var isEditing: Bool = false

    typealias Item = VisitHistory.Item

    var body: some View {
        Section {
            let items = visitHistory.all(withContext: .search)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 220), spacing: 16)], spacing: 16) {
                ForEach(items, id: \.viewId) { item in
                    itemView(item)
                        .popupAnchor()
                }
            }
            .buttonStyle(RecentSearchItemButtonStyle())
        } header: {
            Text("Recently Searched")
            Group {
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
                if isEditing {
                    ClearRecentSearchesButton()
                        .tint(.themedWarning)
                }
            }
            .font(.body)
            .fontWeight(.regular)
        }
        .animation(.easeOut(duration: 0.2), value: isEditing)
    }

    @ViewBuilder
    func itemView(_ item: Item) -> some View {
        itemViewBody(item)
            .overlay(alignment: .topTrailing) {
                VStack {
                    if isEditing {
                        Button("Remove", icon: .general.close) {
                            withAnimation {
                                visitHistory.remove(item, context: .search)
                            }
                        }
                        .symbolVariant(.circle.fill)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.themedContrastingLabel, .themedSecondary)
                        .transition(.scale.combined(with: .opacity))
                        .labelStyle(.iconOnly)
                        .imageScale(.large)
                        .buttonStyle(.plain)

                    }
                }
                .offset(x: 10, y: -10)
            }
    }

    @ViewBuilder
    func itemViewBody(_ item: Item) -> some View {
        switch item {
        case let .community(community):
            Button {
                navigation.push(.community(community, visitContext: .other))
            } label: {
                CommunityListRowBody(community, complications: [.type, .instance])
            }
            .contextMenu(community: community)
        case let .person(person):
            Button {
                navigation.push(.person(person, visitContext: .other))
            } label: {
                PersonListRowBody(person, complications: [.type, .instance])
            }
            .contextMenu(person: person)
        case let .instance(instance):
            Button {
                navigation.push(.instanceStub(instance.instanceStub, visitContext: .other))
            } label: {
                InstanceListRowBody(instance, complications: [.type, .software])
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
