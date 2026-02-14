//
//  Person+Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-06.
//

import MlemMiddleware

extension Person {    
    @MainActor
    func showBanSheet(community: (any DeprecatedCommunity)?, isBannedFromCommunity: Bool, shouldBan: Bool) {
        NavigationModel.main.openSheet(
            .ban(self, isBannedFromCommunity: isBannedFromCommunity, shouldBan: shouldBan, community: community)
        )
    }
    
    func banActions(appState: AppState, community: (any DeprecatedCommunity)?, withUserLabel: Bool = false) -> [any Action] {
        let canBanFromCommunity: Bool
        let showBoth: Bool
        
        let canBanFromInstance = api.isAdmin && api.supports(.banFromInstance, defaultValue: false)
        
        if let myPerson = api.myPerson, let community, let myPersonModerates = myPerson.moderates {
            let supportedByApi = api.supports(.banFromCommunity, defaultValue: false) && (
                apiIsLocal || api.supports(.banFromNonLocalCommunity, defaultValue: false)
            )
            canBanFromCommunity = myPersonModerates(.id(community.id)) && supportedByApi
            showBoth = canBanFromInstance && isBannedFromCommunity(community) != bannedFromInstance
        } else {
            canBanFromCommunity = false
            showBoth = false
        }
        var output: [any Action] = .init()
        // admins should see separate 'ban' and 'unban' actions if ban statuses conflict; otherwise actions are grouped under a single entry (community or instance, depending on moderation status)
        // moderators see community ban action by default, regardless of admin status
        if canBanFromCommunity {
            if showBoth {
                output.append(banFromInstanceAction(appState: appState))
            }
            if let community {
                output.append(banFromCommunityAction(appState: appState, community: community, withUserLabel: withUserLabel))
            }
        }
        // non-moderator admins see instance ban action by default
        else if canBanFromInstance {
            output.append(banFromInstanceAction(appState: appState))
            if showBoth, let community {
                output.append(banFromCommunityAction(appState: appState, community: community, withUserLabel: withUserLabel))
            }
        }
        return output
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
    
    func banFromCommunityAction(appState: AppState, community: any DeprecatedCommunity, withUserLabel: Bool = false) -> BasicAction {
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
    func addAdminAction(instance: any Instance3Providing, isOn: Bool) -> BasicAction {
        let callback: (@MainActor () -> Void) = {
            Task {
                do {
                    try await instance.addAdmin(self, added: !isOn)
                } catch {
                    handleError(error)
                }
            }
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
    
    func addModAction(community: any Community3Providing, isOn: Bool) -> BasicAction {
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
