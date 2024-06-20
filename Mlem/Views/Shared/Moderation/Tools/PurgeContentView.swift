//
//  PurgeContentView.swift
//  Mlem
//
//  Created by Sjmarf on 26/03/2024.
//

import Dependencies
import SwiftUI

protocol Purgable: ContentIdentifiable {
    mutating func purge(reason: String?) async -> Bool
    
    func canPurge() -> Bool
}

struct PurgeContentView: View {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.notifier) var notifier
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
    @Environment(\.dismiss) var dismiss
    
    @State var reason: String = ""
    @FocusState var reasonFocused: FocusedField?
    @State var isWaiting: Bool = false
    
    let content: any Purgable
    let userRemovalWalker: UserRemovalWalker
    
    var title: String {
        if content is PostModel {
            return "Purge Post"
        }
        if content is HierarchicalComment {
            return "Purge Comment"
        }
        if content is UserModel {
            return "Purge User"
        }
        if content is CommunityModel {
            return "Purge Community"
        }
        return "Purge"
    }
    
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
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
    
    var form: some View {
        Form {
            ReasonView(reason: $reason, focusedField: $reasonFocused, showReason: true)
            Section {
                WarningView(
                    iconName: Icons.purge,
                    text: "Purged content cannot is removed permanently from the database and cannot be restored.",
                    inList: true
                )
            }
        }
    }
    
    var userId: Int? {
        if let post = content as? PostModel {
            return post.creator.userId
        } else if let comment = content as? HierarchicalComment {
            return comment.commentView.creator.id
        } else if let user = content as? UserModel {
            return user.userId
        }
        return nil
    }
    
    private func confirm() {
        guard content.canPurge() else {
            assertionFailure("Opened PurgeContentView with unpurgable content!")
            return
        }
        
        isWaiting = true
        
        Task {
            var content = content
            let outcome = await content.purge(reason: reason.isEmpty ? nil : reason)
            if let userId {
                userRemovalWalker.purge(userId: userId)
            }
            if outcome {
                await notifier.add(.success("Purged"))
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

#Preview {
    PurgeContentView(content: CommunityModel.mock(), userRemovalWalker: .init())
}
