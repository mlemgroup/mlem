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

    enum Content {
        case blockable(any Blockable)
        case instance(any InstanceStubProviding)

        func blocked(environment: EnvironmentValues) -> Bool {
            switch self {
            case let .blockable(entity):
                return entity.blocked
            case let .instance(instance):
                if let instance = instance as? any Instance {
                    return instance.blocked
                } else if let session = (environment.appState.firstSession as? UserSession) {
                    return session.blocks?.contains(instance) ?? false
                } else {
                    return false
                }
            }
        }

        var blockable: (any Blockable)? {
            switch self {
            case let .blockable(entity): entity
            default: nil
            }
        }
    }

    let content: [Content]
    let relationship: Relationship

    var availableContent: [Content] {
        content.filter { item in
            switch item {
            case let .blockable(entity as any Person):
                guard let myPersonId = entity.api.myPerson?.id else { return true }
                return entity.id != myPersonId 
            default:
                return true
            }
        }
    }
}

private extension [BlockAction.Content] {
    var contentType: BlockAction.ContentType {
        if self.count > 1 {
            return .multi
        }
        guard let first = self.first else {
            return .other
        } 

        return switch first {
        case .blockable(_ as any Person): .personOnly
        case .blockable(_ as any Community): .communityOnly
        case .instance: .instanceOnly
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
        case let entity as any Person1Providing: BlockAction(content: [.blockable(entity)], relationship: .direct)
        case let entity as any InstanceStubProviding: BlockAction(content: [.instance(entity)], relationship: .direct)
        default: nil
        }
    }

    static let blockCreator = ActionSeed(
        "blockCreator",
        label: BlockAction.createLabel(relationship: .indirect, mode: .block, contentType: .personOnly)
    ) { entity in
        switch entity {
        case let entity as any Comment2Providing: BlockAction(
            content: [.blockable(entity.creator)],
            relationship: .indirect
        )
        case let entity as any Post2Providing: BlockAction(
            content: [.blockable(entity.creator), .blockable(entity.community)],
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
        Self.createLabel(
            relationship: self.relationship,
            mode: content.first!.blocked(environment: environment) ? .unblock : .block,
            contentType: availableContent.contentType
        ).withVisibility(visibility(environment))
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        let canInteract = content.allSatisfy {
            switch $0 {
            case let .blockable(entity):
                entity.api.canInteract(appState: environment.appState)
            case .instance:
                true
            }
        }
        guard canInteract else { return .hidden }

        if let person = content.compactMap({ $0.blockable as? any Person }).first {
            guard let myPersonId = person.api.myPerson?.id else { return .hidden }
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
        let actions: [PopupAnchorModel.Action] = content.map { item in
            .init(title: item.blockable is any Person ? "User" : "Community", isDestructive: true) {
                submit(content: item, environment: environment)
            }
        }
        environment.popupModel?.showPopup(message: "Block...", actions)
    }

    @MainActor
    func execute(entity content: Content, environment: EnvironmentValues) {
        if content.blocked(environment: environment) {
            submit(content: content, environment: environment)
            return 
        }

        let label: LocalizedStringResource = switch content {
        case .blockable(_ as any Person): "Really block this user?"
        case .blockable(_ as any Community): "Really block this community?"
        default: "Really block this instance?"
        }

        environment.popupModel?.showPopup(message: label, [
            .init(title: "Yes", isDestructive: true) {
                submit(content: content, environment: environment)
            }
        ])
    }

    private func submit(content: Content, environment: EnvironmentValues) {
        Task {
            let shouldBlock = !content.blocked(environment: environment)
            let didSucceed = await updateBlocked(
                content,
                environment: environment,
                newValue: shouldBlock
            )
            let toast = createToast(didBlock: shouldBlock, didSucceed: didSucceed) {
                Task { await updateBlocked(
                    content,
                    environment: environment,
                    newValue: false
                ) }
            }
            environment.toastModel?.add(toast)
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

    private func updateBlocked(
        _ content: Content,
        environment: EnvironmentValues,
        newValue: Bool
    ) async -> Bool {
        switch content {
        case let .blockable(entity):
            return await entity.updateBlocked(newValue).value == .succeeded
        case let .instance(instance):
            return await updateBlocked(
                instance: instance,
                environment: environment,
                newValue: newValue
            )
        }
    }

    private func updateBlocked(
        instance: any InstanceStubProviding,
        environment: EnvironmentValues,
        newValue: Bool
    ) async -> Bool {
        if let instance = instance as? any Instance1Providing, instance.api.token != nil {
            let task = instance.toggleBlocked()
            return await task.value == .succeeded
        } else if let session = (environment.appState.firstSession as? UserSession) {
            let result = await session.toggleInstanceBlock(actorId: instance.actorId)
            return result == .succeeded
        } else {
            return false
        }
    }
}
