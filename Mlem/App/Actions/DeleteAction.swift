//
//  DeleteAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-17.
//

import Actions
import MlemMiddleware
import SwiftUI

struct DeleteAction: SimpleLabelAction {
    let entity: any DeletableProviding
}

// MARK: - Configurability

extension ActionSeed {
    static let delete = ActionSeed("delete") { entity in
        switch entity {
        case let entity as any DeletableProviding: DeleteAction(entity: entity)
        default: nil
        }
    }
}

// MARK: - Appearance

extension DeleteAction {
    static let deleteLabel: ActionLabel = .init(
        "Delete",
        icon: .general.delete,
        color: .themedNegative,
        isDestructive: true
    )
    static let restoreLabel: ActionLabel = .init(
        "Restore",
        icon: .lemmy.restore,
        color: .themedPositive
    )
    
    static var label: ActionLabel { deleteLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        if entity.deleted {
            Self.restoreLabel.withVisibility(visibility(environment))
        } else {
            Self.deleteLabel.withVisibility(visibility(environment))
        }
    }
    
    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        
        guard let myPersonId = entity.api.myPerson?.id else { return .hidden }
        guard entity.isOwnContent(myPersonId: myPersonId) else { return .hidden }
        guard !entity.deleted || canUndelete else { return .hidden }
        
        return .enabled
    }
}

// MARK: - Behavior

extension DeleteAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.popupModel?.showPopup(message: "Really delete?", [
            .init(title: "Yes", isDestructive: true) {
                entity.toggleDeleted { status in
                    let toast = createToast(didDelete: entity.deleted, requestStatus: status)
                    environment.toastModel?.add(toast)
                }
            }
        ])
    }
    
    var canUndelete: Bool {
        switch entity {
        case is any Message1Providing:
            entity.api.supports(.undeletePrivateMessages, defaultValue: true)
        default:
            true
        }
    }
    
    private func createToast(didDelete: Bool, requestStatus: UpdateStatus) -> ToastType {
        switch (didDelete, requestStatus) {
        case (true, .success): createConfirmationToast()
        case (true, .failure): .failure("Failed to delete!")
        case (false, .success): .success("Restored")
        case (false, .failure): .failure("Failed to restore!")
        }
    }
    
    private func createConfirmationToast() -> ToastType {
        if canUndelete {
            .undoable(
                "Deleted",
                icon: .general.delete,
                callback: { entity.updateDeleted(false, callback: nil) },
                color: .themedNegative
            )
        } else {
            .basic(
                "Deleted",
                icon: .general.delete,
                color: .themedNegative
            )
        }
    }
}
