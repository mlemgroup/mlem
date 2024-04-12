//
//  RemovePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-27.
//

import Dependencies
import SwiftUI

struct RemovePostView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.notifier) var notifier
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
    @Environment(\.dismiss) var dismiss
    
    @State var reason: String = ""
    @FocusState var reasonFocused: FocusedField?
    @State var isWaiting: Bool = false
    
    @State var post: any Removable
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
        .navigationTitle("\(verb) Post")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func confirm() {
        isWaiting = true
        
        Task {
            let success = await post.remove(reason: reason.isEmpty ? nil : reason, shouldRemove: shouldRemove)
            DispatchQueue.main.async {
                if success {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        Task {
                            await notifier.add(.success("\(verb)d post"))
                        }
                    }
                } else {
                    isWaiting = false
                }
            }
        }
    }
}
