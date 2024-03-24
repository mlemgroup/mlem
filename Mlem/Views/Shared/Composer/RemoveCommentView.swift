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
    @State var shouldPurge: Bool = false
    
    let comment: HierarchicalComment
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
            .navigationTitle("\(verb) Comment")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    var form: some View {
        Form {
            ReasonView(reason: $reason, focusedField: $reasonFocused, showReason: shouldRemove)
            if siteInformation.isAdmin, shouldRemove {
                Section {
                    Toggle("Purge", isOn: $shouldPurge)
                        .tint(.red)
                } footer: {
                    // swiftlint:disable:next line_length
                    Text("Permanently remove this comment, its replies, its attachments and any other related data from the database. This cannot be undone.")
                }
            }
        }
    }
    
    private func confirm() {
        isWaiting = true
        
        Task {
            let reason = reason.isEmpty ? nil : reason
            if shouldPurge {
                let outcome: Bool
                do {
                    outcome = try await apiClient.purgeComment(id: comment.commentView.id, reason: reason).success
                    DispatchQueue.main.async {
                        comment.purged = true
                    }
                } catch {
                    outcome = false
                    errorHandler.handle(error)
                }
                if outcome {
                    await notifier.add(.success("Purged comment"))
                    DispatchQueue.main.async {
                        dismiss()
                    }
                } else {
                    DispatchQueue.main.async {
                        isWaiting = false
                    }
                }
            } else {
                let response: CommentResponse?
                do {
                    response = try await apiClient.removeComment(id: comment.commentView.id, shouldRemove: shouldRemove, reason: reason)
                } catch {
                    response = nil
                    errorHandler.handle(error)
                }
                
                if let response, response.commentView.comment.removed == shouldRemove {
                    await notifier.add(.success("\(verb)d comment"))
                    DispatchQueue.main.async {
                        comment.commentView.comment.removed = shouldRemove
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
