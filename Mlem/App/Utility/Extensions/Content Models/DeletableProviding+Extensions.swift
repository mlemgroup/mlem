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
            let task = toggleDeleted()
            Task {
                let result = await task.result.get()
                switch result {
                case .succeeded:
                    ToastModel.main.add(
                        .undoable(
                            "Deleted",
                            icon: .general.delete,
                            callback: { self.updateDeleted(false) },
                            color: .themedNegative
                        )
                    )
                case .failed:
                    ToastModel.main.add(.failure("Failed to delete post!"))
                default:
                    handleError(MlemError.unexpectedValue, silent: true)
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
