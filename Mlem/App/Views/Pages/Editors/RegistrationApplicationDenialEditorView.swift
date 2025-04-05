//
//  RegistrationApplicationDenialEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-14.
//

import ComponentViews
import MlemMiddleware
import SwiftUI

struct RegistrationApplicationDenialEditorView: View {
    @Environment(\.dismiss) var dismiss
    
    let application: RegistrationApplication
    
    @State var reason: String = ""
    @FocusState var reasonFocused: Bool
    @State var presentationSelection: PresentationDetent = .large

    var body: some View {
        CollapsibleSheetView(presentationSelection: $presentationSelection, canDismiss: reason.isEmpty) {
            NavigationStack {
                Form {
                    TextField("Reason (Optional)", text: $reason, axis: .vertical)
                        .focused($reasonFocused)
                }
                .scrollDismissesKeyboard(.interactively)
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Deny Application")
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
        let result = await application.deny(reason: reason.isEmpty ? nil : reason).result.get()
        switch result {
        case .succeeded:
            HapticManager.main.play(haptic: .success, priority: .low)
            dismiss()
        case .failed:
            ToastModel.main.add(.failure())
        default:
            break
        }
    }
}
