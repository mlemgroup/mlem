//
//  BlockAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI
import MlemBackend

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
        appearance: BlockAction.createAppearance(relationship: .direct, mode: .block, contentType: .multi)
    ) { entity in
        switch entity {
        case let entity as any Blockable: BlockAction(content: [entity], relationship: .direct)
        default: nil
        }
    }

    static let blockCreator = ActionSeed(
        "blockCreator",
        appearance: BlockAction.createAppearance(relationship: .indirect, mode: .block, contentType: .multi)
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

    typealias Titles = (currentState: LocalizedStringResource, stateTransition: LocalizedStringResource)

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    static func createAppearance(relationship: Relationship, mode: Mode, contentType: ContentType) -> ActionAppearance {
        let titles: Titles = switch (relationship, mode, contentType) {
        case (.direct, .block, _):
            (
            currentState: "Unblocked",
            stateTransition: "Block"
            )
        case (.direct, .unblock, _):
            (
            currentState: "Blocked",
            stateTransition: "Unblock"
            )
        case (.indirect, .block, .personOnly):
            (
            currentState: "User Unblocked",
            stateTransition: "Block User"
            )
        case (.indirect, .unblock, .personOnly):
            (
            currentState: "User Blocked",
            stateTransition: "Unblock User"
            )
        case (.indirect, .block, .communityOnly):
            (
            currentState: "Community Unblocked",
            stateTransition: "Block Community"
            )
        case (.indirect, .unblock, .communityOnly):
            (
            currentState: "Community Blocked",
            stateTransition: "Unblock Community"
            )
        case (.indirect, .block, .instanceOnly):
            (
            currentState: "Instance Unblocked",
            stateTransition: "Block Instance"
            )
        case (.indirect, .unblock, .instanceOnly):
            (
            currentState: "Instance Blocked",
            stateTransition: "Unblock Instance"
            )
        case (.indirect, .block, .multi):
            (
            currentState: "Block...",
            stateTransition: "Block..."
            )
        case (.indirect, .unblock, .multi):
            (
            currentState: "Unblock...",
            stateTransition: "Unblock..."
            )
        case (_, _, .other):
            (
            currentState: "Block...",
            stateTransition: "Block..."
            )
        }

        return switch mode {
        case .block: .init(
            currentStateLabel: .init(titles.currentState, icon: .lemmy.blocked.representingState(active: false)),
            stateTransitionLabel: .init(titles.stateTransition, icon: .lemmy.block),
            color: .themedNegative,
            isDestructive: true
        )
        case .unblock: .init(
            currentStateLabel: .init(titles.currentState, icon: .lemmy.blocked.representingState(active: true)),
            stateTransitionLabel: .init(titles.stateTransition, icon: .lemmy.unblock),
            color: .themedPositive,
            prominent: true
        )
        }
    }

    func createAppearance(environment: EnvironmentValues) -> ActionAppearance {
        Self.createAppearance(
            relationship: self.relationship,
            mode: content.first!.blocked(environment: environment) ? .unblock : .block,
            contentType: availableContent.contentType
        ).withVisibility(visibility(environment))
    }

    // swiftlint:disable:next cyclomatic_complexity
    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        let canInteract = content.allSatisfy {
            if $0 is any InstanceActionProviding {
                return true
            } else if let contentModel = $0 as? ContentModel {
                return contentModel.api.canInteract(appState: environment.appState) && $0.updateBlocked != nil
            }
            return false
        }
        guard canInteract else { return .hidden }

        for item in content {
            switch item {
            case let person as Person:
                guard let myPersonId = person.api.myPerson?.id else { return .hidden }
                guard person.id != myPersonId else { return .hidden }
            case let instance as any InstanceActionProviding:
                let api = environment.appState.firstApi
                guard api.canInteract(appState: environment.appState) else { return .hidden }
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
            let callback = {
                submit(entity: item, environment: environment)
            }
            let appearance = Self.createAppearance(
                relationship: .indirect,
                mode: item.blocked(environment: environment) ? .unblock : .block,
                contentType: item is Person ? .personOnly : .communityOnly
            )
            return .init(
                title: appearance.label(describing: .stateTransition).title,
                isDestructive: appearance.isDestructive,
                callback: callback
            )
        }
        environment.popupModel?.showPopup(message: "User or community?", actions)
    }

    @MainActor
    func execute(entity: any Blockable, environment: EnvironmentValues) {
        if entity.blocked(environment: environment) {
            submit(entity: entity, environment: environment)
            return
        }

        let label: String

        switch entity {
        case _ as Person:
            label = .init(localized: "Really block this user?")
        case _ as Community:
            label = .init(localized: "Really block this community?")
        case _ as any InstanceActionProviding:
            label = .init(localized: "Really block this instance?")
        default:
            assertionFailure()
            label = "Really block?"
        }

        environment.popupModel?.showPopup(message: label, [
            .init(title: "Yes", isDestructive: true) {
                submit(entity: entity, environment: environment)
            }
        ])
    }

    private func submit(entity: any Blockable, environment: EnvironmentValues) {
        let shouldBlock = !entity.blocked(environment: environment)
        if let updateBlocked = entity.updateBlocked {
            updateBlocked(shouldBlock) { didSucceed in
                let toast = createToast(didBlock: shouldBlock, didSucceed: didSucceed) {
                    updateBlocked(!shouldBlock, nil)
                }
                environment.toastModel?.add(toast)
            }
        } else if entity is any InstanceActionProviding, let session = (environment.appState.firstSession as? UserSession) {
            session.updateInstanceBlock(actorId: entity.actorId, shouldBlock: shouldBlock) { didSucceed in
                let toast = createToast(didBlock: shouldBlock, didSucceed: didSucceed) {
                    session.updateInstanceBlock(actorId: entity.actorId, shouldBlock: !shouldBlock)
                }
                environment.toastModel?.add(toast)
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
