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
    
    @Environment(\.dismiss) var dismiss
    
    @State var reason: String = ""
    @FocusState var reasonFocused: FocusedField?
    
    let post: PostModel
    let shouldRemove: Bool
    
    var verb: String { shouldRemove ? "Remove" : "Restore" }
    
    var body: some View {
        form
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
                    // .disabled(isWaiting)
                }
                ToolbarItem(placement: .topBarTrailing) {
//                    if isWaiting {
//                        ProgressView()
//                    } else {
                        Button("Confirm", systemImage: Icons.send, action: confirm)
//                     }
                }
            }
            .navigationTitle("\(verb) Post")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    var form: some View {
        Form {
            ReasonView(reason: $reason, focusedField: $reasonFocused, showReason: true)
        }
    }
    
    private func confirm() {
        // print("Confirmed")
        Task {
            do {
                _ = try await apiClient.removePost(id: post.postId, shouldRemove: shouldRemove, reason: reason)
                await notifier.add(.success("\(verb)d post"))
                dismiss()
            } catch {
                errorHandler.handle(error)
            }
        }
    }
}
