//
//  ContentPurgeEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-10-26.
//

import ComponentViews
import Haptics
import MlemMiddleware
import SwiftUI

struct ContentPurgeEditorView: View {
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
    @Environment(\.dismiss) var dismiss
    
    let target: any PurgableProviding
    
    @State var community: ExpectedValue<(any Community)>?
    @State var reason: String = ""
    @FocusState var reasonFocused: Bool
    @State var presentationSelection: PresentationDetent = .large
    
    init(target: any PurgableProviding) {
        self.target = target
        self._community = .init(wrappedValue: (target as? any InteractableProviding)?.community)
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
                        ExpectedView(community) { community in
                            RulesListView(model: community, reason: $reason)
                        }
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
                        CloseButtonView(ios18Label: .cancel)
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Send", icon: .lemmy.send) {
                            Task { await send() }
                        }
                        .glassProminentButtonStyle()
                    }
                }
            }
            .onAppear { reasonFocused = true }
        }
    }
    
    func send() async {
        do {
            try await target.purge(reason: reason.isEmpty ? nil : reason)
            hapticManager.play(haptic: .success, tier: .low)
            dismiss()
        } catch {
            handleError(error)
        }
    }
}
