//
//  NewSwipeActionEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2026-03-04.
//

import Actions
import SwiftUI

struct NewSwipeActionEditorView: View {
    @Binding var configuration: ActionSeedSwipeConfiguration
    let onReset: () -> Void
    let onApplyToAll: (() -> Void)?
    let allActions: [ActionSeed]

    @State var showingApplyToAllConfirmation: Bool = false

    var body: some View {
        Form {
            ActionListView(
                title: "Left",
                actions: Binding(get: { configuration.leading }, set: { configuration.leading = $0 }),
                allActions: allActions
            )
            ActionListView(
                title: "Right",
                actions: Binding(get: { configuration.trailing }, set: { configuration.trailing = $0 }),
                allActions: allActions
            )
            Button("Reset", action: onReset)
            if let onApplyToAll {
                Button("Apply to All") { showingApplyToAllConfirmation = true }
                    .confirmationDialog(
                        "Really apply this configuration to all other content types?",
                        isPresented: $showingApplyToAllConfirmation,
                        titleVisibility: .visible
                    ) {
                        Button("Yes", action: onApplyToAll)
                    }
            }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Swipe Actions")
    }
}

extension NewSwipeActionEditorView {
    init<Configuration: SwipeActionConfiguration>(
        _ keyPath: ReferenceWritableKeyPath<SettingsValues, Configuration>,
        onApplyToAll onApplyToAllConfiguration: ((Configuration) -> Void)? = nil
    ) {
        let onApplyToAll: (() -> Void)?
        if let onApplyToAllConfiguration {
            onApplyToAll = {
                onApplyToAllConfiguration(Settings.get(keyPath))
            }
        } else {
            onApplyToAll = nil
        }

        self.init(
            configuration: .init(
                get: {
                    Settings.get(keyPath).swipes
                }, set: {
                    var configuration = Settings.get(keyPath)
                    configuration.swipes = $0
                    Settings.set(keyPath, to: configuration)
                }
            ),
            onReset: {
                var configuration = Settings.get(keyPath)
                configuration.swipes = Configuration.defaultSwipes
                Settings.set(keyPath, to: configuration)
            },
            onApplyToAll: onApplyToAll,
            allActions: Configuration.availableActions.all
        )
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
