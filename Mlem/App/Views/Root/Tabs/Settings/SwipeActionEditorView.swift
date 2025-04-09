//
//  SwipeActionEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-26.
//

import SwiftUI

struct SwipeActionEditorView<Configuration: InteractionBarConfiguration>: View {
    @State var configuration: Configuration
    @State var showingApplyToAllConfirmation: Bool = false
    let isReport: Bool
    
    let onSet: (Configuration) -> Void
    
    init(configuration: Configuration, isReport: Bool, onSet: @escaping (Configuration) -> Void) {
        self.configuration = configuration
        self.isReport = isReport
        self.onSet = onSet
    }
    
    init(setting: WritableKeyPath<InteractionBarTracker, Configuration>, isReport: Bool) {
        self.init(configuration: InteractionBarTracker.main[keyPath: setting], isReport: isReport) {
            var main = InteractionBarTracker.main
            main[keyPath: setting] = $0
        }
    }
    
    var body: some View {
        Form {
            ActionListView(title: "Left", actions: $configuration.leadingSwipes)
            ActionListView(title: "Right", actions: $configuration.trailingSwipes)
            Button("Reset") {
                let defaultConfiguration: Configuration = isReport ? .reportDefault ?? .default : .default
                var newConfiguration = configuration
                newConfiguration.leadingSwipes = defaultConfiguration.leadingSwipes
                newConfiguration.trailingSwipes = defaultConfiguration.trailingSwipes
                configuration = newConfiguration
            }
            Button("Apply to All") { showingApplyToAllConfirmation = true }
                .confirmationDialog(
                    "Really apply this configuration to all other content types?",
                    isPresented: $showingApplyToAllConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Yes") {
                        let configurations = InteractionBarTracker.main.interactionBarConfigurations
                        InteractionBarTracker.main.interactionBarConfigurations = .init(
                            post: configurations.post.applying(other: configuration, types: [.swipe]),
                            comment: configurations.comment.applying(other: configuration, types: [.swipe]),
                            reply: configurations.reply.applying(other: configuration, types: [.swipe]),
                            // Don't apply to report overrides
                            postReport: InteractionBarTracker.main.interactionBarConfigurations.postReport,
                            commentReport: InteractionBarTracker.main.interactionBarConfigurations.commentReport
                        )
                    }
                }
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Swipe Actions")
        .onChange(of: configuration) { onSet(configuration) }
    }
}

private struct ActionListView<ActionType: ActionTypeProviding>: View {
    let title: LocalizedStringResource
    @Binding var actions: [ActionType]
    
    var body: some View {
        Section(title) {
            ForEach(Array(actions.enumerated()), id: \.element) { _, action in
                HStack {
                    Label(action.appearance.label, systemImage: action.appearance.swipeIcon2)
                        .tint(action.appearance.color)
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
        Menu("Add", systemImage: Icons.add) {
            ForEach(Array(ActionType.allCases), id: \.self) { action in
                Button(action.appearance.label, systemImage: action.appearance.barIcon) {
                    actions.append(action)
                }
                .disabled(actions.contains(action))
            }
        }
    }
}
