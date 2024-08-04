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
                let result = try await task.result.get()
                switch result {
                case .succeeded:
                    ToastModel.main.add(
                        .undoable(
                            "Deleted",
                            systemImage: Icons.deleteFill,
                            callback: { self.updateDeleted(false) },
                            color: Palette.main.negative
                        )
                    )
                case .failed:
                    ToastModel.main.add(.failure("Failed to delete post!"))
                default:
                    print("Unexpected `toggleDeleted` result type")
                }
            }
        } else {
            toggleDeleted()
        }
    }
    
    func deleteAction(feedback: Set<FeedbackType>) -> BasicAction {
        .init(
            id: "delete\(uid)",
            isOn: deleted,
            label: deleted ? "Restore" : "Delete",
            color: deleted ? Palette.main.positive : Palette.main.negative,
            isDestructive: !deleted,
            confirmationPrompt: deleted ? nil : "Really delete?",
            icon: deleted ? Icons.undelete : Icons.delete,
            callback: api.isAuthenticatedAndActive ? { self.toggleDeleted(feedback: feedback) } : nil
        )
    }
}
