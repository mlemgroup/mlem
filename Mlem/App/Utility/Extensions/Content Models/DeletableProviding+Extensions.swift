//
//  DeletableProviding+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 22/07/2024.
//

import MlemMiddleware

extension DeletableProviding {
    func toggleDeleted(feedback: Set<FeedbackType>) {
        if feedback.contains(.toast), !deleted {
            toggleDeleted { status in
                switch status {
                case .success:
                    if self is any Message1Providing, !self.api.supports(.undeletePrivateMessages, defaultValue: true) {
                        ToastModel.main.add(
                            .basic(
                                "Deleted",
                                icon: .general.delete,
                                color: .themedNegative
                            )
                        )
                    } else {
                        ToastModel.main.add(
                            .undoable(
                                "Deleted",
                                icon: .general.delete,
                                callback: { self.updateDeleted(false, callback: nil) },
                                color: .themedNegative
                            )
                        )
                    }
                case .failure:
                    ToastModel.main.add(.failure("Failed to delete post!"))
                }
            }
        } else {
            toggleDeleted()
        }
    }
    
    func deleteAction(appState: AppState, feedback: Set<FeedbackType>) -> BasicAction {
        .init(
            id: "delete\(uid)",
            appearance: .init(
                label: deleted ? "Restore" : "Delete",
                isOn: deleted,
                isDestructive: !deleted,
                color: deleted ? .themedPositive : .themedNegative,
                icon: deleted ? Icons.undelete : Icons.delete
            ),
            confirmationPrompt: deleted ? nil : "Really delete?",
            callback: api.canInteract(appState: appState) ? { @MainActor in self.toggleDeleted(feedback: feedback) } : nil
        )
    }
}
