//
//  SwipeActionEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-03-26.
//

import SwiftUI

struct SwipeActionEditorView<Configuration: InteractionBarConfiguration>: View {
    @Setting(\.interactionBar_post) var postInteractionBar
    @Setting(\.interactionBar_comment) var commentInteractionBar
    @Setting(\.interactionBar_reply) var replyInteractionBar
    
    @State var configuration: Configuration
    @State var showingApplyToAllConfirmation: Bool = false
    let isReport: Bool
    
    let onSet: (Configuration) -> Void
    
    init(configuration: Configuration, isReport: Bool, onSet: @escaping (Configuration) -> Void) {
        self.configuration = configuration
        self.isReport = isReport
        self.onSet = onSet
    }
    
    init(setting: ReferenceWritableKeyPath<SettingsValues, Configuration>, isReport: Bool) {
        self.init(configuration: Settings.get(setting), isReport: isReport) { Settings.set(setting, to: $0) }
    }
    
    var body: some View {
        Form {
            Button("Reset") {
                let defaultConfiguration: Configuration = isReport ? .reportDefault ?? .default : .default
                var newConfiguration = configuration
                newConfiguration.savedSwipes = defaultConfiguration.savedSwipes
                configuration = newConfiguration
            }
            Button("Apply to All") { showingApplyToAllConfirmation = true }
                .confirmationDialog(
                    "Really apply this configuration to all other content types?",
                    isPresented: $showingApplyToAllConfirmation,
                    titleVisibility: .visible
                ) {
                    Button("Yes") {
                        postInteractionBar = postInteractionBar.applying(other: configuration, types: [.swipe])
                        commentInteractionBar = commentInteractionBar.applying(other: configuration, types: [.swipe])
                        replyInteractionBar = replyInteractionBar.applying(other: configuration, types: [.swipe])
                        // reports intentionally omitted
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
            ForEach(actions, id: \.hashValue) { action in
                HStack {
                    Label(action.appearance.label, systemImage: action.appearance.swipeIcon2)
                        .gradientTint(action.appearance.color)
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
            ForEach(Array(ActionType.allCases), id: \.self) { action in
                Button(action.appearance.label, systemImage: action.appearance.barIcon) {
                    actions.append(action)
                }
                .disabled(actions.contains(action))
            }
        }
    }
}
