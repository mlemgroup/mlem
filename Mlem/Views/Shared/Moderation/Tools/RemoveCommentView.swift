//
//  RemoveCommentView.swift
//  Mlem
//
//  Created by Sam Marfleet on 22/03/2024.
//

import Dependencies
import SwiftUI

struct RemoveCommentView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.notifier) var notifier
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
    @Environment(\.dismiss) var dismiss
    
    @State var reason: String = ""
    @FocusState var reasonFocused: FocusedField?
    @State var isWaiting: Bool = false
    
    @State var comment: any Removable
    let shouldRemove: Bool
    
    var verb: String { shouldRemove ? "Remove" : "Restore" }
    
    var body: some View {
        Form {
            ReasonView(reason: $reason, focusedField: $reasonFocused, showReason: shouldRemove)
        }
        .onAppear {
            reasonFocused = .reason
        }
        .toolbar {
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") { reasonFocused = nil }
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
                .tint(.red)
                .disabled(isWaiting)
            }
            ToolbarItem(placement: .topBarTrailing) {
                if isWaiting {
                    ProgressView()
                } else {
                    Button("Confirm", systemImage: Icons.send, action: confirm)
                }
            }
        }
        .allowsHitTesting(!isWaiting)
        .opacity(isWaiting ? 0.5 : 1)
        .interactiveDismissDisabled(isWaiting)
        .navigationTitle("\(verb) Comment")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func confirm() {
        isWaiting = true
        
        Task {
            let success = await comment.remove(reason: reason.isEmpty ? nil : reason, shouldRemove: shouldRemove)
            DispatchQueue.main.async {
                if success {
                    dismiss()
                } else {
                    isWaiting = false
                }
            }
        }
    }
}
