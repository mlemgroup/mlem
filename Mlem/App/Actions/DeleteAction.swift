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
    static let deleteAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Not Deleted", icon: .general.deleted.representingState(active: false)),
        stateTransitionLabel: .init("Delete", icon: .general.delete),
        color: .themedNegative,
        isDestructive: true
    )
    static let restoreAppearance: ActionAppearance = .init(
        currentStateLabel: .init("Deleted", icon: .general.deleted.representingState(active: true)),
        stateTransitionLabel: .init("Restore", icon: .lemmy.restore),
        color: .themedPositive,
        prominent: true
    )

    static var appearance: ActionAppearance { deleteAppearance }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        if entity.deleted {
            Self.restoreAppearance.withVisibility(visibility(environment))
        } else {
            Self.deleteAppearance.withVisibility(visibility(environment))
        }
    }
    
    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        
        guard let myPersonId = entity.api.myPerson?.id else { return .hidden }
        guard entity.isOwnContent(myPersonId: myPersonId) else { return .hidden }
        
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
    
    private func createToast(didDelete: Bool, requestStatus: UpdateStatus) -> ToastType {
        switch (didDelete, requestStatus) {
        case (true, .success): createConfirmationToast()
        case (true, .failure): .failure("Failed to delete!")
        case (false, .success): .success("Restored")
        case (false, .failure): .failure("Failed to restore!")
        }
    }
    
    private func createConfirmationToast() -> ToastType {
        .undoable(
            "Deleted",
            icon: .general.delete,
            callback: { entity.updateDeleted(false, callback: nil) },
            color: .themedNegative
        )
    }
}
