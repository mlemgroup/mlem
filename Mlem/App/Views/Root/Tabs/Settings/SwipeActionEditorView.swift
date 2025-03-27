//
//  SwipeActionEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-26.
//

import SwiftUI

struct SwipeActionEditorView<Configuration: InteractionBarConfiguration>: View {
    @State var configuration: Configuration {
        didSet { onSet(configuration) }
    }
    
    let onSet: (Configuration) -> Void
    
    init(configuration: Configuration, onSet: @escaping (Configuration) -> Void) {
        self.configuration = configuration
        self.onSet = onSet
    }
    
    init(setting: WritableKeyPath<InteractionBarTracker, Configuration>) {
        self.init(configuration: InteractionBarTracker.main[keyPath: setting]) {
            print("SET")
            var main = InteractionBarTracker.main
            main[keyPath: setting] = $0
        }
    }
    
    var body: some View {
        Form {
            ActionListView(title: "Left", actions: $configuration.leadingSwipes)
            ActionListView(title: "Right", actions: $configuration.trailingSwipes)
        }
        .navigationTitle("Swipe Actions")
        .environment(\.editMode, .constant(.active))
    }
}

private struct ActionListView<ActionType: ActionTypeProviding>: View {
    let title: LocalizedStringResource
    @Binding var actions: [ActionType]
    
    var body: some View {
        Section(title) {
            ForEach(Array(actions.enumerated()), id: \.element) { index, action in
                Label(action.appearance.label, systemImage: action.appearance.swipeIcon2)
                    .tint(action.appearance.color)
                    .tag(action)
//                    .swipeActions(edge: .trailing) {
//                        Button("Remove", role: .destructive) {
//                            actions.remove(at: index)
//                        }
//                        .tint(.themedWarning)
//                    }
                    .contextMenu {
                        Button("Remove", systemImage: "minus.circle", role: .destructive) {
                            actions.remove(at: index)
                        }
                    }
            }
            .onMove { from, tom in
                print(from, tom)
            }
            .labelStyle(.squircle)
            addButtonView
                .disabled(actions.count >= 3)
        }
    }
    
    @ViewBuilder
    var addButtonView: some View {
        Menu("Add", systemImage: Icons.add) {
            ForEach(Array(ActionType.allCases), id: \.self) { action in
                Button(action.appearance.label, systemImage: action.appearance.barIcon) {
                    actions.append(action)
                }
            }
        }
    }
}
