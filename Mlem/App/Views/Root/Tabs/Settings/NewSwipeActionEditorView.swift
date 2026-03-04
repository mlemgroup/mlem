//
//  NewSwipeActionEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-04.
//

import Actions
import SwiftUI

struct NewSwipeActionEditorView: View {
    @Setting(\.interactionBar_community) var configuration
    
    var body: some View {
        Form {
            ActionListView(
                title: "Left",
                actions: Binding(get: { configuration.swipes.leading }, set: { configuration.swipes.leading = $0 }),
                allActions: CommunityActionConfiguration.availableActions.all
            )
            ActionListView(
                title: "Right",
                actions: Binding(get: { configuration.swipes.trailing }, set: { configuration.swipes.trailing = $0 }),
                allActions: CommunityActionConfiguration.availableActions.all
            )
            Button("Reset") {
                configuration = .init()
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Swipe Actions")
    }
}

private struct ActionListView: View {
    let title: LocalizedStringResource
    @Binding var actions: [ActionSeed]
    var allActions: [ActionSeed]
    
    var body: some View {
        Section(title) {
            ForEach(actions, id: \.hashValue) { action in
                HStack {
                    Label(action.label.title, icon: action.label.icon)
                        .symbolVariant(.fill)
                        .gradientTint(action.label.color)
                    Spacer()
                }
                .tag(action)
            }
            .onMove { old, new in
                actions.move(fromOffsets: old, toOffset: new)
            }
            .onDelete { offsets in
                actions.remove(atOffsets: offsets)
            }
            .labelStyle(.squircle)
            addButtonView
                .disabled(actions.count >= 3)
        }
    }
    
    @ViewBuilder
    var addButtonView: some View {
        Menu("Add", icon: .general.add) {
            ForEach(allActions, id: \.self) { action in
                Button(action.label.title, icon: action.label.icon) {
                    actions.append(action)
                }
                .disabled(actions.contains(action))
            }
        }
    }
}
