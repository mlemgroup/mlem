//
//  RegistrationApplicationDenialEditorView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-01-14.
//

import ComponentViews
import Haptics
import MlemMiddleware
import SwiftUI

struct RegistrationApplicationDenialEditorView: View {
    @Environment(HapticManager.self) var hapticManager
    @Environment(ToastModel.self) var toastModel
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
                        CloseButtonView()
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Send", icon: .lemmy.send) {
                            Task { await send() }
                        }
                        .buttonStyle(.glassProminent)
                    }
                }
            }
            .onAppear { reasonFocused = true }
        }
    }
    
    func send() async {
        application.deny(reason: reason.isEmpty ? nil : reason) { result in
            switch result {
            case .success:
                hapticManager.play(haptic: .success, tier: .low)
                dismiss()
            case .failure:
                toastModel.add(.failure())
            }
        }
    }
}
