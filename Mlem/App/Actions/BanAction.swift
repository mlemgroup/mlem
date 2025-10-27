//
//  BanAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

private enum BanScope {
    case community
    case instance
}

private extension Set<BanScope> {
    static let communityOnly: Set<BanScope> = [.community]
    static let instanceOnly: Set<BanScope> = [.instance]
    static let both: Set<BanScope> = [.community, .instance]
    static let none: Set<BanScope> = []
}

private struct BanScopePattern {
    let closure: (Set<BanScope>) -> Bool

    static func ~= (lhs: BanScopePattern, rhs: Set<BanScope>) -> Bool {
        lhs.closure(rhs)
    }
}

private extension BanScopePattern {
    static func anyContaining(_ value: BanScope) -> BanScopePattern {
        BanScopePattern { $0.contains(value) }
    }

    static func anyNotContaining(_ value: BanScope) -> BanScopePattern {
        BanScopePattern { !$0.contains(value) }
    }
}

struct BanAction: ConfigurableAction {
    let entity: any Person1Providing

    var canBanFromInstance: Bool {
        entity.api.isAdmin && entity.api.supports(.banFromInstance, defaultValue: false)
    }

    func canBanFromCommunity(community: (any Community1Providing)?) -> Bool {
        let supportedByApi = entity.api.supports(.banFromCommunity, defaultValue: false) && (
            entity.apiIsLocal || entity.api.supports(.banFromNonLocalCommunity, defaultValue: false)
        )

        guard supportedByApi else { return false }
        guard let community else { return entity.api.isAdmin }
        guard let myPerson = entity.api.myPerson else { return false }

        return myPerson.moderates(community: community) || entity.api.isAdmin
    }
}

// MARK: - Configurability

extension ActionSeed {
    static let banCreator = ActionSeed("banCreator") { entity in
        switch entity {
        case let entity as any Comment2Providing: BanAction(entity: entity.creator)
        default: nil
        }
    }
}

// MARK: - Appearance

extension BanAction {
    static let label: ActionLabel = .init("Ban", icon: .lemmy.banFromCommunity, isDestructive: true)

    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        let label: ActionLabel

        let appliedBanScopes = getAppliedBanScopes(environment: environment)
        let actionableBanScopes = getActionableBanScopes(environment: environment)

        switch (bannedFrom: appliedBanScopes, canBanFrom: actionableBanScopes) {
        case (bannedFrom: .none, canBanFrom: .both),
             (bannedFrom: .anyNotContaining(.community), canBanFrom: .instanceOnly):
            label = .init("Ban", icon: .lemmy.banFromInstance, isDestructive: true)

        case (bannedFrom: .anyContaining(.instance), canBanFrom: .instanceOnly),
             (bannedFrom: .both, canBanFrom: .both):
            label = .init("Unban", icon: .lemmy.unbanFromInstance)

        case (bannedFrom: .instanceOnly, canBanFrom: .both),
             (bannedFrom: .communityOnly, canBanFrom: .both):
            label = .init("Ban...", icon: .lemmy.banFromInstance, isDestructive: true)

        case (bannedFrom: .anyContaining(.community), canBanFrom: .communityOnly):
            label = .init("Unban", icon: .lemmy.unbanFromCommunity)

        case (bannedFrom: .anyNotContaining(.community), canBanFrom: .communityOnly):
            label = Self.label

        default:
            return Self.label.withVisibility(.hidden)
        }

        return label.withVisibility(visibility(environment))
    }

    /// Get the scopes that the target is current banned within.
    private func getAppliedBanScopes(environment: EnvironmentValues) -> Set<BanScope> {
        var output: Set<BanScope> = []
        if isBannedFromCommunity(environment: environment) {
            output.insert(.community)
        }
        if entity.bannedFromInstance {
            output.insert(.instance)
        }
        return output
    }

    /// Get the set of ban scopes that the authorized user is able to apply to the target.
    private func getActionableBanScopes(environment: EnvironmentValues) -> Set<BanScope> {
        var output: Set<BanScope> = []
        if canBanFromCommunity(community: environment.communityContext) {
            output.insert(.community)
        }
        if entity.api.isAdmin {
            output.insert(.instance)
        }
        return output
    }

    private func isBannedFromCommunity(environment: EnvironmentValues) -> Bool {
        guard let communityContext = environment.communityContext else { return false }
        return entity.isBannedFromCommunity(communityContext) ?? false
    }

    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        
        guard let myPersonId = entity.api.myPerson?.id else { return .hidden }
        return entity.id == myPersonId ? .hidden : .enabled
    }
}

// MARK: - Behavior

extension BanAction {
    // If `nil` is returned, a modal should be shown asking whether the user wants to ban or unban
    private func shouldBan(environment: EnvironmentValues) -> Bool? {
        let bannedFromCommunity = isBannedFromCommunity(environment: environment)
        let bannedFromInstance = entity.bannedFromInstance

        if canBanFromInstance {
            switch (bannedFromCommunity, bannedFromInstance) {
            case (false, false):
                return true
            case (true, true):
                return false
            default:
                return nil
            }
        } else {
            return !bannedFromCommunity
        }
    }

    @MainActor
    func execute(environment: EnvironmentValues) {
        if let shouldBan = shouldBan(environment: environment) {
            showBanSheet(environment: environment, shouldBan: shouldBan)
        } else {
            showAlert(environment: environment)
        }
    }

    @MainActor
    private func showAlert(environment: EnvironmentValues) {
        var actions: [PopupAnchorModel.Action] = []

        if entity.bannedFromInstance {
            actions.append(
                .init(title: "Unban from Instance", isDestructive: false) {
                    showBanSheet(environment: environment, shouldBan: false)
                }
            )
        } else {
            actions.append(
                .init(title: "Ban from Instance", isDestructive: true) {
                    showBanSheet(environment: environment, shouldBan: true)
                }
            )
        }

        if isBannedFromCommunity(environment: environment) {
            actions.append(
                .init(title: "Unban from Community", isDestructive: false) {
                    showBanSheet(environment: environment, shouldBan: false)
                }
            )
        } else {
            actions.append(
                .init(title: "Ban from Community", isDestructive: true) {
                    showBanSheet(environment: environment, shouldBan: true)
                }
            )
        }

        environment.popupModel?.showPopup(message: "Choose an action...", actions)
    }

    @MainActor
    private func showBanSheet(environment: EnvironmentValues, shouldBan: Bool) {
        environment.navigation?.openSheet(.ban(
            entity,
            isBannedFromCommunity: isBannedFromCommunity(environment: environment),
            shouldBan: shouldBan,
            community: environment.communityContext
        ))
    }
}
