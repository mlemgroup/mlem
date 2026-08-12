//
//  Person+Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-06.
//

import MlemMiddleware

extension Person {    
    @MainActor
    func showBanSheet(community: Community?, isBannedFromCommunity: Bool, shouldBan: Bool) {
        NavigationModel.main.openSheet(
            .ban(self, isBannedFromCommunity: isBannedFromCommunity, shouldBan: shouldBan, community: community)
        )
    }
    
    func banFromInstanceAction(appState: AppState, withUserLabel: Bool = false) -> BasicAction {
        .init(
            id: "banFromInstance\(uid)",
            appearance: .banFromInstance(isOn: bannedFromInstance, withUserLabel: withUserLabel),
            callback: api.canInteract(appState: appState) && api.isAdmin ? { @MainActor in
                self.showBanSheet(
                    community: nil,
                    isBannedFromCommunity: false,
                    shouldBan: !self.bannedFromInstance
                )
            } : nil
        )
    }
    
    func banFromCommunityAction(appState: AppState, community: Community, withUserLabel: Bool = false) -> BasicAction {
        let isBanned = isBannedFromCommunity(community)
        let callback: (@MainActor () -> Void)?
        if let isBanned, api.canInteract(appState: appState), community.canModerate {
            callback = {
                self.showBanSheet(
                    community: community,
                    isBannedFromCommunity: isBanned,
                    shouldBan: !isBanned
                )
            }
        } else {
            callback = nil
        }
        
        return .init(
            id: "banFromCommunity\(uid)",
            appearance: .banFromCommunity(isOn: isBanned ?? false, withUserLabel: withUserLabel),
            callback: callback
        )
    }
    
    /// Action to add/remove admin
    /// - Parameters:
    ///   - instance: instance to add the admin to
    ///   - isOn: true if the user is already an admin, false otherwise
    func addAdminAction(instance: Instance, isOn: Bool) -> BasicAction {
        let callback: (@MainActor () -> Void) = {
            instance.addAdmin(personId: self.id, added: !isOn)
        }
        
        return .init(
            id: "addAdmin\(uid)",
            appearance: .addAdmin(isOn: isOn),
            confirmationPrompt: isOn
                ? "Really remove administrator \(displayName) from \(instance.displayName)?"
                : "Really appoint \(displayName) as an administrator of \(instance.displayName)?",
            callback: callback
        )
    }
    
    func addModAction(community: Community, isOn: Bool) -> BasicAction {
        let callback: (@MainActor () -> Void) = {
            Task {
                do {
                    try await community.addModerator(self, added: !isOn)
                } catch {
                    handleError(error)
                }
            }
        }
        
        return .init(
            id: "addMod\(uid)",
            appearance: .addMod(isOn: isOn),
            confirmationPrompt: isOn
                ? "Really remove moderator \(displayName) from \(community.displayName)?"
                : "Really appoint \(displayName) as a moderator of \(community.displayName)?",
            callback: callback
        )
    }
}
