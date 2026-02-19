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
            case let .blockable(entity as Person):
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
        case .blockable(_ as Person): .personOnly
        case .blockable(_ as Community): .communityOnly
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
        case let entity as any InstanceStubProviding: BlockAction(content: [.instance(entity)], relationship: .direct)
        case let entity as any Blockable: BlockAction(content: [.blockable(entity)], relationship: .direct)
        default: nil
        }
    }

    static let blockCreator = ActionSeed(
        "blockCreator",
        label: BlockAction.createLabel(relationship: .indirect, mode: .block, contentType: .personOnly)
    ) { entity in
        switch entity {
        case let entity as Comment:
            if let creator = entity.creator.value {
                BlockAction(
                    content: [.blockable(creator)],
                    relationship: .indirect)
            } else {
                nil
            }
        case let entity as Post:
            if let creator = entity.creator.value, let community = entity.community.value {
                BlockAction(
                    content: [.blockable(creator), .blockable(community)],
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
        Self.createLabel(
            relationship: self.relationship,
            mode: content.first!.blocked(environment: environment) ? .unblock : .block,
            contentType: availableContent.contentType
        ).withVisibility(visibility(environment))
    }

    // swiftlint:disable:next cyclomatic_complexity
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

        for item in content {
            switch item {
            case let .blockable(person as Person):
                guard let myPersonId = person.api.myPerson?.id else { return .hidden }
                guard person.id != myPersonId else { return .hidden }
            case let .instance(instance):
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
            .init(title: item.blockable is Person ? "User" : "Community", isDestructive: true) {
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

        let label: String

        switch content {
        case .blockable(_ as Person):
            label = .init(localized: "Really block this user?")
        case .blockable(_ as Community):
            label = .init(localized: "Really block this community?")
        case .instance:
            label = .init(localized: "Really block this instance?")
        default:
            assertionFailure()
            label = ""
        }

        environment.popupModel?.showPopup(message: label, [
            .init(title: "Yes", isDestructive: true) {
                submit(content: content, environment: environment)
            }
        ])
    }

    private func submit(content: Content, environment: EnvironmentValues) {
        let shouldBlock = !content.blocked(environment: environment)
        
        switch content {
        case let .instance(instance):
            submitForInstance(instance: instance, shouldBlock: shouldBlock, environment: environment)
        case let .blockable(blockable):
            submitForBlockable(blockable: blockable, environment: environment)
        }
    }
    
    private func submitForBlockable(blockable: any Blockable, environment: EnvironmentValues) {
        let shouldBlock = !blockable.blocked
        blockable.updateBlocked(shouldBlock) { didSucceed in
            let toast = createToast(didBlock: shouldBlock, didSucceed: didSucceed) {
                blockable.updateBlocked(!shouldBlock, callback: nil)
            }
            environment.toastModel?.add(toast)
        }
    }
    
    private func submitForInstance(instance: any InstanceStubProviding, shouldBlock: Bool, environment: EnvironmentValues) {
        Task {
            let didSucceed = await updateInstanceBlocked(
                instance: instance,
                environment: environment,
                newValue: shouldBlock
            )
            let toast = createToast(didBlock: shouldBlock, didSucceed: didSucceed) {
                Task { await updateInstanceBlocked(
                    instance: instance,
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

    private func updateInstanceBlocked(
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
