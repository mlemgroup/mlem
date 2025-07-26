//
//  ContentRemovalEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 09/10/2024.
//

import ComponentViews
import Haptics
import MlemMiddleware
import SwiftUI

struct ContentRemovalEditorView: View {
    @Environment(AppState.self) var appState
    @Environment(HapticManager.self) var hapticManager
    @Environment(\.dismiss) var dismiss
    
    enum Mode {
        case remove, restore
    }
    
    let target: any RemovableProviding
    @State var mode: Mode
    
    @State var community: (any Community)?
    @State var reason: String = ""
    @FocusState var reasonFocused: Bool
    @State var presentationSelection: PresentationDetent = .large
    
    init(target: any RemovableProviding) {
        self.target = target
        self._mode = .init(wrappedValue: target.removed ? .restore : .remove)
        self._community = .init(wrappedValue: (target as? any Interactable2Providing)?.community)
    }
    
    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: reason.isEmpty) {
            NavigationStack {
                Form {
                    TextField("Reason (Optional)", text: $reason, axis: .vertical)
                        .focused($reasonFocused)
                    if mode == .remove {
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
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle(mode == .restore ? "Restore" : "Remove")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Send", icon: .lemmy.send) {
                            send()
                        }
                    }
                }
            }
            .onAppear { reasonFocused = true }
        }
    }
    
    func send() {
        target.toggleRemoved(reason: reason) { status in
            switch status {
            case .success:
                hapticManager.play(haptic: .success, tier: .low)
                dismiss()
            case let .failure(error):
                handleError(error)
            }
        }
    }
}
