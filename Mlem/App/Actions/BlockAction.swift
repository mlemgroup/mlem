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
    enum Relationship { case direct, indirect }

    enum ContentType {
        case personOnly, communityOnly, multi, other
    }

    let content: [any Blockable]
    let relationship: Relationship

    var availableContent: [any Blockable] {
        content.filter { entity in
            if let entity = entity as? any Person {
                guard let myPersonId = entity.api.myPerson?.id else { return true }
                return entity.id != myPersonId 
            } else {
                return true
            }
        }
    }
}

private extension [any Blockable] {
    var contentType: BlockAction.ContentType {
        if self.count > 1 {
            return .multi
        }
        guard let first = self.first else {
            return .other
        } 

        return switch first {
        case is any Person: .personOnly
        case is any Community: .communityOnly
        default: .other
        }
    }
}

// MARK: - Configurability

extension ActionSeed {
    static let block = ActionSeed(
        "block",
        label: BlockAction.createLabel(relationship: .direct, mode: .block, contentType: .multi)
    ) { entity in
        switch entity {
        case let entity as any Person1Providing: BlockAction(content: [entity], relationship: .direct)
        default: nil
        }
    }

    static let blockCreator = ActionSeed(
        "blockCreator",
        label: BlockAction.createLabel(relationship: .indirect, mode: .block, contentType: .personOnly)
    ) { entity in
        switch entity {
        case let entity as any Comment2Providing: BlockAction(
            content: [entity.creator],
            relationship: .indirect
        )
        case let entity as any Post2Providing: BlockAction(
            content: [entity.creator, entity.community],
            relationship: .indirect
        )
        default: nil
        }
    }
}

// MARK: - Appearance

extension BlockAction {
    enum Mode { case block, unblock }

    // swiftlint:disable:next cyclomatic_complexity
    static func createLabel(relationship: Relationship, mode: Mode, contentType: ContentType) -> ActionLabel {
        let label: LocalizedStringResource = switch (relationship, mode, contentType) {
        case (.direct, .block, _): "Block"
        case (.direct, .unblock, _): "Unblock"
        case (.indirect, .block, .personOnly): "Block User"
        case (.indirect, .unblock, .personOnly): "Unblock User"
        case (.indirect, .block, .communityOnly): "Block Community"
        case (.indirect, .unblock, .communityOnly): "Unblock Community"
        case (.indirect, .block, .multi): "Block..."
        case (.indirect, .unblock, .multi): "Unblock..."
        case (_, _, .other): "Block..."
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
            mode: content.first!.blocked ? .unblock : .block,
            contentType: availableContent.contentType
        ).withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        let canInteract = content.allSatisfy { $0.api.canInteract(appState: environment.appState) }
        guard canInteract else { return .hidden }

        guard let first = content.first else {
            assertionFailure()
            return .hidden
        }
        
        if let person = content.compactMap({ $0 as? any Person }).first {
            guard let myPersonId = first.api.myPerson?.id else { return .hidden }
            guard person.id != myPersonId else { return .hidden }
        }

        return .enabled
    }
}

// MARK: - Behavior

extension BlockAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        if availableContent.count > 1 {
            executeMulti(environment: environment)
            return
        }

        guard let first = availableContent.first else {
            assertionFailure()
            return
        }

        execute(entity: first, environment: environment)
    }

    @MainActor
    func executeMulti(environment: EnvironmentValues) {
        let actions: [PopupAnchorModel.Action] = content.map { entity in
            .init(title: entity is any Person ? "User" : "Community", isDestructive: true) {
                Task {
                    let response = await entity.toggleBlocked().value
                    let toast = createToast(didBlock: entity.blocked, requestStatus: response) {
                        entity.updateBlocked(false)
                    }
                    environment.toastModel?.add(toast)
                }
            }
        }
        environment.popupModel?.showPopup(message: "Block...", actions)
    }

    @MainActor
    func execute(entity: any Blockable, environment: EnvironmentValues) {
        environment.popupModel?.showPopup(message: "Really block this user?", [
            .init(title: "Yes", isDestructive: true) {
                Task {
                    let response = await entity.toggleBlocked().value
                    let toast = createToast(didBlock: entity.blocked, requestStatus: response) {
                        entity.updateBlocked(false)
                    }
                    environment.toastModel?.add(toast)
                }
            }
        ])
    }

    private func createToast(
        didBlock: Bool,
        requestStatus: StateUpdateResult,
        undo: @escaping () -> Void
    ) -> ToastType {
        switch (didBlock, requestStatus) {
        case (true, .succeeded): .undoable(
                "Blocked",
                icon: .lemmy.block,
                callback: undo,
                color: .themedNegative
            )
        case (true, _): .failure("Failed to block!")
        case (false, .succeeded): .basic("Unblocked", icon: .lemmy.unblock)
        case (false, _): .failure("Failed to unblock!")
        }
    }
}
