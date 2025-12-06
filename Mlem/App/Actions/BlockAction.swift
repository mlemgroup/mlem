//
//  BlockAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct BlockAction: ConfigurableAction {
    let entity: any Person1Providing
}

// MARK: - Configurability

extension ActionSeed {
    static let block = ActionSeed("block") { entity in
        switch entity {
        case let entity as any Person1Providing: BlockAction(entity: entity)
        default: nil
        }
    }

    static let blockCreator = ActionSeed("blockCreator") { entity in
        switch entity {
        case let entity as any Comment2Providing: BlockAction(entity: entity.creator)
        default: nil
        }
    }
}

// MARK: - Appearance

extension BlockAction {
    static let blockLabel: ActionLabel = .init(
        "Block User",
        icon: .lemmy.block,
        color: .themedNegative,
        isDestructive: true
    )
    static let unblockLabel: ActionLabel = .init(
        "Unblock User",
        icon: .lemmy.unblock,
        color: .themedPositive
    )
    
    static var label: ActionLabel { blockLabel }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        if entity.blocked {
            Self.unblockLabel.withVisibility(visibility(environment))
        } else {
            Self.blockLabel.withVisibility(visibility(environment))
        }
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        
        guard let myPersonId = entity.api.myPerson?.id else { return .hidden }
        return entity.id == myPersonId ? .hidden : .enabled
    }
}

// MARK: - Behavior

extension BlockAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.popupModel?.showPopup(message: "Really block this user?", [
            .init(title: "Yes", isDestructive: true) {
                Task {
                    let response = await entity.toggleBlocked().value
                    let toast = createToast(didBlock: entity.blocked, requestStatus: response)
                    environment.toastModel?.add(toast)
                }
            }
        ])
    }

    private func createToast(didBlock: Bool, requestStatus: StateUpdateResult) -> ToastType {
        switch (didBlock, requestStatus) {
        case (true, .succeeded): .undoable(
                "Blocked",
                icon: .lemmy.block,
                callback: { entity.updateBlocked(false) },
                color: .themedNegative
            )
        case (true, _): .failure("Failed to block!")
        case (false, .succeeded): .basic("Unblocked", icon: .lemmy.unblock)
        case (false, _): .failure("Failed to unblock!")
        }
    }
}
