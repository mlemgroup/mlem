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
        case personOnly, communityOnly, instanceOnly, multi, other
    }

    let content: [any Blockable]
    let relationship: Relationship

    var availableContent: [any Blockable] {
        content.filter { item in
            switch item {
            case let entity as Person:
                guard let myPersonId = entity.api.myPerson?.id else { return true }
                return entity.id != myPersonId 
            default:
                return true
            }
        }
    }
}

private extension [Blockable] {
    var contentType: BlockAction.ContentType {
        if self.count > 1 {
            return .multi
        }
        guard let first = self.first else {
            return .other
        } 

        return switch first {
        case _ as Person: .personOnly
        case _ as Community: .communityOnly
        case _ as Instance: .instanceOnly
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
        case let entity as any Blockable: BlockAction(content: [entity], relationship: .direct)
        default: nil
        }
    }

    static let blockCreator = ActionSeed(
        "blockCreator",
        label: BlockAction.createLabel(relationship: .indirect, mode: .block, contentType: .multi)
    ) { entity in
        switch entity {
        case let entity as Comment:
            if let creator = entity.creator.value {
                BlockAction(
                    content: [creator],
                    relationship: .indirect)
            } else {
                nil
            }
        case let entity as Post:
            if let creator = entity.creator.value, let community = entity.community.value {
                BlockAction(
                    content: [creator, community],
                    relationship: .indirect)
            } else {
                nil
            }
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
        case (.indirect, .block, .instanceOnly): "Block Instance"
        case (.indirect, .unblock, .instanceOnly): "Unblock Instance"
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
        let firstContent = content.first!
        var blocked: Bool
        if let instance = firstContent as? Instance {
            blocked = instance.blocked(from: environment.appState.firstSession.api) ?? instance.blocked_.realizedValue
        } else {
            blocked = firstContent.blocked.realizedValue
        }
        
        return Self.createLabel(
            relationship: self.relationship,
            mode: blocked ? .unblock : .block,
            contentType: availableContent.contentType
        ).withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        let canInteract = content.allSatisfy {
            $0 is Instance || ($0.api.canInteract(appState: environment.appState) && $0.updateBlocked != nil)
        }
        guard canInteract else { return .hidden }

        for item in content {
            switch item {
            case let person as Person:
                guard let myPersonId = person.api.myPerson?.id else { return .hidden }
                guard person.id != myPersonId else { return .hidden }
            case let instance as Instance:
                let api = environment.appState.firstApi
                guard api.supports(.blockInstances, defaultValue: false) else { return .hidden }
                guard api.actorId != instance.actorId else { return .hidden }
            default:
            break
            }
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
        let actions: [PopupAnchorModel.Action] = content.map { item in
            .init(title: item is Person ? "User" : "Community", isDestructive: true) {
                submit(entity: item, environment: environment)
            }
        }
        environment.popupModel?.showPopup(message: "Block...", actions)
    }

    @MainActor
    func execute(entity: any Blockable, environment: EnvironmentValues) {
        if entity.blocked.realizedValue {
            submit(entity: entity, environment: environment)
            return
        }

        let label: String

        switch entity {
        case _ as Person:
            label = .init(localized: "Really block this user?")
        case _ as Community:
            label = .init(localized: "Really block this community?")
        case _ as Instance:
            label = .init(localized: "Really block this instance?")
        default:
            assertionFailure()
            label = ""
        }

        environment.popupModel?.showPopup(message: label, [
            .init(title: "Yes", isDestructive: true) {
                submit(entity: entity, environment: environment)
            }
        ])
    }

    private func submit(entity: any Blockable, environment: EnvironmentValues) {
        if let updateBlocked = entity.updateBlocked {
            let shouldBlock = !entity.blocked.realizedValue
            updateBlocked(shouldBlock) { didSucceed in
                let toast = createToast(didBlock: shouldBlock, didSucceed: didSucceed) {
                    updateBlocked(!shouldBlock, nil)
                }
                environment.toastModel?.add(toast)
            }
        } else if entity is Instance,
                  let session = (environment.appState.firstSession as? UserSession) {
            Task {
                await session.toggleInstanceBlock(actorId: entity.actorId)
            }
        } else {
            assertionFailure("Failed to block entity")
        }
    }

    private func createToast(
        didBlock: Bool,
        didSucceed: Bool,
        undo: @escaping () -> Void
    ) -> ToastType {
        switch (didBlock, didSucceed) {
        case (true, true): .undoable(
                "Blocked",
                icon: .lemmy.block,
                callback: undo,
                color: .themedNegative
            )
        case (true, false): .failure("Failed to block!")
        case (false, true): .basic("Unblocked", icon: .lemmy.unblock)
        case (false, false): .failure("Failed to unblock!")
        }
    }
}
