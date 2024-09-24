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
            appearance: .init(
                label: deleted ? "Restore" : "Delete",
                isOn: deleted,
                isDestructive: !deleted,
                color: deleted ? Palette.main.positive : Palette.main.negative,
                icon: deleted ? Icons.undelete : Icons.delete
            ),
            confirmationPrompt: deleted ? nil : "Really delete?",
            callback: api.canInteract ? { self.toggleDeleted(feedback: feedback) } : nil
        )
    }
}
