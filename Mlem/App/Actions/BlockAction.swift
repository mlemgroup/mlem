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
    enum Content: Hashable {
        case person(any Person1Providing)
        case community(any Community1Providing)

        var entity: any Blockable {
            switch self {
            case let .person(person): person
            case let .community(community): community
            }
        }

        var blocked: Bool {
            switch self {
            case let .person(person): person.blocked
            case let .community(community): community.blocked
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.entity.actorId == rhs.entity.actorId
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(entity.actorId)
        }
    }

    enum Relationship { case direct, indirect }

    enum ContentType { case personOnly, communityOnly, multi }

    let content: Set<Content>
    let relationship: Relationship
}

extension Set<BlockAction.Content> {
    var contentType: BlockAction.ContentType {
        if self.count > 1 {
            return .multi
        }
        guard let first = self.first else {
            assertionFailure()
            return .multi
        } 

        return switch first {
        case .person: .personOnly
        case .community: .communityOnly
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
        case let entity as any Person1Providing: BlockAction(content: [.person(entity)], relationship: .direct)
        default: nil
        }
    }

    static let blockCreator = ActionSeed(
        "blockCreator",
        label: BlockAction.createLabel(relationship: .indirect, mode: .block, contentType: .personOnly)
    ) { entity in
        switch entity {
        case let entity as any Comment2Providing: BlockAction(
            content: [.person(entity.creator)],
            relationship: .indirect
        )
        case let entity as any Post2Providing: BlockAction(
            content: [.person(entity.creator), .community(entity.community)],
            relationship: .indirect
        )
        default: nil
        }
    }
}

// MARK: - Appearance

extension BlockAction {
    enum Mode { case block, unblock }

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
            mode: content.first!.entity.blocked ? .unblock : .block,
            contentType: content.contentType
        ).withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        let canInteract = content.allSatisfy { $0.entity.api.canInteract(appState: environment.appState) }
        guard canInteract else { return .hidden }

        guard let first = content.first else {
            assertionFailure()
            return .hidden
        }
        
        if let person = content.compactMap({ $0.entity as? any Person }).first {
            guard let myPersonId = first.entity.api.myPerson?.id else { return .hidden }
            guard person.id != myPersonId else { return .hidden }
        }

        return .enabled
    }
}

// MARK: - Behavior

extension BlockAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        if content.count > 1 {
            executeMulti(environment: environment)
            return
        }

        guard let first = content.first else {
            assertionFailure()
            return
        }

        execute(entity: first.entity, environment: environment)
    }

    @MainActor
    func executeMulti(environment: EnvironmentValues) {
        var actions: [PopupAnchorModel.Action] = content.map(\.entity).map { entity in
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
