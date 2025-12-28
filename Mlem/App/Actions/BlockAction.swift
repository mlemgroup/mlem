//
//  BlockAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct BlockAction: Actions.Action {
    enum Relationship { case identity, author }

    let entity: any Person1Providing
    let relationship: Relationship
}

// MARK: - Configurability

extension ActionSeed {
    static let block = ActionSeed(
        "block",
        label: BlockAction.createLabel(relationship: .identity, mode: .block)
    ) { entity in
        switch entity {
        case let entity as any Person1Providing: BlockAction(entity: entity, relationship: .identity)
        default: nil
        }
    }

    static let blockCreator = ActionSeed(
        "blockCreator",
        label: BlockAction.createLabel(relationship: .author, mode: .block)
    ) { entity in
        switch entity {
        case let entity as any Comment2Providing: BlockAction(entity: entity.creator, relationship: .author)
        case let entity as any Post2Providing: BlockAction(entity: entity.creator, relationship: .author)
        default: nil
        }
    }
}

// MARK: - Appearance

extension BlockAction {
    enum Mode { case block, unblock }

    static func createLabel(relationship: Relationship, mode: Mode) -> ActionLabel {
        let label: LocalizedStringResource = switch (relationship, mode) {
        case (.identity, .block): "Block"
        case (.identity, .unblock): "Unblock"
        case (.author, .block): "Block User"
        case (.author, .unblock): "Unblock User"
        }

        return switch mode {
        case .block: .init(
            label,
            icon: .lemmy.block,
            color: .themedNegative,
            isDestructive: true
        )
        case .unblock: .init(
            label,
            icon: .lemmy.unblock,
            color: .themedPositive
        )
        }
    }

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.createLabel(
            relationship: self.relationship,
            mode: entity.blocked ? .unblock : .block
        ).withVisibility(visibility(environment))
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
