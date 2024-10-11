//
//  ContentRemovalEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 09/10/2024.
//

import MlemMiddleware
import SwiftUI

struct ContentRemovalEditorView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    enum Mode {
        case remove, restore
    }
    
    let target: any Interactable2Providing
    @State var mode: Mode
    
    @State var community: any Community
    @State var reason: String = ""
    @FocusState var reasonFocused: Bool
    @State var presentationSelection: PresentationDetent = .large
    
    init(target: any Interactable2Providing) {
        self.target = target
        self._mode = .init(wrappedValue: target.removed ? .restore : .remove)
        self._community = .init(wrappedValue: target.community)
    }

    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: reason.isEmpty) {
            NavigationStack {
                Form {
                    TextField("Reason (Optional)", text: $reason, axis: .vertical)
                        .focused($reasonFocused)
                    if mode == .remove {
                        ReasonPickerView(reason: $reason, community: community)
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
        switch await target.toggleRemoved(reason: reason).result.get() {
        case .succeeded:
            HapticManager.main.play(haptic: .success, priority: .low)
            dismiss()
        default:
            ToastModel.main.add(.failure())
        }
    }
}
