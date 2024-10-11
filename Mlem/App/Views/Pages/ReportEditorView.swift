//
//  ReportEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 11/08/2024.
//

import MlemMiddleware
import SwiftUI

struct ReportEditorView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    let target: any ReportableProviding
    
    @State var community: (any Community)?
    @State var reason: String = ""
    @FocusState var reasonFocused: Bool
    @State var presentationSelection: PresentationDetent = .large
    
    init(target: any ReportableProviding, community: AnyCommunity?) {
        self.target = target
        
        if let community {
            self._community = .init(wrappedValue: community.wrappedValue as? any Community)
        } else if let community = (target as? any Interactable2Providing)?.community {
            self._community = .init(wrappedValue: community)
        } else {
            self._community = .init(wrappedValue: nil)
        }
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
            try await target.report(reason: reason)
            HapticManager.main.play(haptic: .success, priority: .low)
            dismiss()
        } catch {
            handleError(error)
        }
    }
}
