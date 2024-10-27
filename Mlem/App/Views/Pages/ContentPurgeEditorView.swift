//
//  ContentPurgeEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2024-10-26.
//

import MlemMiddleware
import SwiftUI

struct ContentPurgeEditorView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
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
                    TextField("Reason (Optional)", text: $reason, axis: .vertical)
                        .focused($reasonFocused)
                    ReasonPickerView(reason: $reason, community: community)
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Purge")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Send", systemImage: Icons.send) {
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
