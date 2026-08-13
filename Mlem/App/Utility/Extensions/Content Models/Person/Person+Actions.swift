//
//  Person+Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-06.
//

import MlemMiddleware

extension Person {
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
