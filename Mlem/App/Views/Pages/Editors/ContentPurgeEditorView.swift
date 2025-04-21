//
//  ContentPurgeEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-10-26.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct ContentPurgeEditorView: View {
    @Environment(AppState.self) var appState
    @Environment(\.dismiss) var dismiss
    
    let target: any PurgableProviding
    
    @State var community: (any Community)?
    @State var reason: String = ""
    @FocusState var reasonFocused: Bool
    @State var presentationSelection: PresentationDetent = .large
    
    init(target: any PurgableProviding) {
        self.target = target
        self._community = .init(wrappedValue: (target as? any Interactable2Providing)?.community)
    }

    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: reason.isEmpty) {
            NavigationStack {
                Form {
                    Section {
                        WarningView(
                            icon: .lemmy.purge,
                            text: "Purged content is erased from the database and cannot be restored.",
                            inList: true
                        )
                    }
                    Section {
                        TextField("Reason (Optional)", text: $reason, axis: .vertical)
                            .focused($reasonFocused)
                    }
                    Section {
                        ReasonShortcutView(reason: $reason)
                    }
                    if let community {
                        RulesListView(model: community, reason: $reason)
                    }
                    if let instance = appState.firstSession.instance {
                        RulesListView(model: instance, reason: $reason)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Purge")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Send", icon: .lemmy.send) {
                            Task {
                                await send()
                            }
                        }
                    }
                }
            }
            .onAppear { reasonFocused = true }
        }
    }
    
    func send() async {
        do {
            try await target.purge(reason: reason.isEmpty ? nil : reason)
            HapticManager.main.play(haptic: .success, priority: .low)
            dismiss()
        } catch {
            handleError(error)
        }
    }
}
