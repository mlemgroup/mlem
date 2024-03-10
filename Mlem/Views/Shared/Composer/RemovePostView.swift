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
    @State var shouldPurge: Bool = false
    
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
    
    var form: some View {
        Form {
            ReasonView(reason: $reason, focusedField: $reasonFocused, showReason: true)
            if siteInformation.isAdmin, shouldRemove {
                Section {
                    Toggle("Purge", isOn: $shouldPurge)
                        .tint(.red)
                } footer: {
                    // swiftlint:disable:next line_length
                    Text("Permanently remove this post, its comments, its attachments and any other related data from the database. This cannot be undone.")
                }
            }
        }
    }
    
    private func confirm() {
        isWaiting = true
        
        Task {
            if shouldPurge {
                let outcome = await post.purge(reason: reason.isEmpty ? nil: reason)
                if outcome {
                    await notifier.add(.success("purged post"))
                    DispatchQueue.main.async {
                        dismiss()
                    }
                } else {
                    DispatchQueue.main.async {
                        isWaiting = false
                    }
                }
            } else {
                await post.toggleRemove(reason: reason.isEmpty ? nil : reason)
                
                if post.post.removed == shouldRemove {
                    await notifier.add(.success("\(verb)d post"))
                    DispatchQueue.main.async {
                        dismiss()
                    }
                } else {
                    DispatchQueue.main.async {
                        isWaiting = false
                    }
                }
            }
        }
    }
}
