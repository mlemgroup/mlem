//
//  Person1Providing+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 02/07/2024.
//

import Foundation
import MlemMiddleware

extension Person1Providing {
    var shouldHideInFeed: Bool { blocked || purged }
    
    func flairs(
        interactableContext interactable: (any Interactable2Providing)? = nil,
        communityContext community: (any Community)? = nil
    ) -> [PersonFlair] {
        @Setting(\.person_ageVisibility) var alwaysShowAccountAge
        
        let community = community ?? interactable?.community
        var output: Set<PersonFlair> = []
        
        if isMlemDeveloper {
            output.insert(.developer)
        }
        if isBot {
            output.insert(.bot)
        }
        if bannedFromInstance {
            output.insert(.bannedFromInstance)
        }
        if let community, isBannedFromCommunity(community) ?? false {
            output.insert(.bannedFromCommunity)
        }
        
        if (alwaysShowAccountAge == .newAccountsOnly && createdRecently) || alwaysShowAccountAge == .always {
            output.insert(.accountAge(created))
        } else if isCakeDay {
            output.insert(.cakeDay)
        }
        
        if let interactable {
            assert(interactable.creator.actorId == actorId)
            output.formUnion(interactable.contextualFlairs())
        } else {
            if api.myInstance?.administrators.contains(where: { $0.id == id }) ?? false {
                output.insert(.admin)
            }
        }
        
        if let community, community.moderators_?.contains(where: { $0.id == id }) ?? false {
            output.insert(.moderator)
        }
        
        return output.sorted { $0.sortVal < $1.sortVal }
    }
    
    @MainActor
    func showBanSheet(community: (any Community)?, isBannedFromCommunity: Bool, shouldBan: Bool) {
        NavigationModel.main.openSheet(
            .ban(self, isBannedFromCommunity: isBannedFromCommunity, shouldBan: shouldBan, community: community)
        )
    }
    
    func toggleBlocked(feedback: Set<FeedbackType> = []) {
        if feedback.contains(.toast) {
            if !blocked {
                ToastModel.main.add(
                    .undoable(
                        "Blocked",
                        icon: .lemmy.block,
                        callback: {
                            self.updateBlocked(false)
                        },
                        color: .themedNegative
                    )
                )
            } else {
                ToastModel.main.add(
                    .undoable(
                        "Unblocked",
                        icon: .lemmy.unblock,
                        callback: {
                            self.updateBlocked(true)
                        },
                        color: .themedPrimary
                    )
                )
            }
        }
        toggleBlocked()
    }
    
    @ActionBuilder
    func menuActions(
        appState: AppState,
        feedback: Set<FeedbackType> = [.haptic, .toast],
        isInMessageFeed: Bool = false,
        navigation: NavigationLayer?,
        community: (any Community)?
    ) -> [any Action] {
        ActionGroup {
            openInstanceAction(navigation: navigation)
            copyNameAction()
            shareAction(navigation: navigation)
            if (AppState.main.firstSession as? UserSession)?.person?.person1 !== person1 {
                if !isInMessageFeed {
                    sendMessageAction()
                }
                blockAction(appState: appState, feedback: feedback)
            }
        }
        ActionGroup {
            if let navigation, api.supports(.modlog, defaultValue: false) {
                openModlogAction(
                    appState: appState,
                    navigation: navigation,
                    feedback: feedback
                )
            }
            banActions(appState: appState, community: community)
            if api.isAdmin {
                if api.supports(.purgeContent, defaultValue: false) {
                    purgeAction(appState: appState)
                }
            }
            
            if let community3 = community as? any Community3Providing,
               let myPerson = api.myPerson,
               api.supports(.editModeratorList, defaultValue: false),
               myPerson.canModerate(self, in: community3) {
                addModAction(community: community3, isOn: community3.moderators.contains(where: { $0.id == id }))
            }
            
            if apiIsLocal, api.isAdmin, let myInstance = api.myInstance {
                if api.isHigherAdmin(than: self) {
                    addAdminAction(instance: myInstance, isOn: true)
                } else if !(self.isAdmin_ ?? false) {
                    addAdminAction(instance: myInstance, isOn: false)
                }
            }
        }
    }
    
    func blockAction(appState: AppState, feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "block\(uid)",
            appearance: .block(isOn: blocked),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.toggleBlocked(feedback: feedback) } : nil
        )
    }
    
    func sendMessageAction() -> BasicAction {
        .init(
            id: "sendMessage\(uid)",
            appearance: .init(label: "Send Message", color: .themedAccent, icon: Icons.message),
            callback: { NavigationModel.main.openSheet(.messageFeed(self, focusTextField: true)) }
        )
    }

    func openModlogAction(appState: AppState, navigation: NavigationLayer, feedback: Set<FeedbackType>) -> ActionGroup {
        .init(
            appearance: .init(
                label: "Modlog",
                color: .themedModeration,
                icon: Icons.modlog
            ),
            prompt: "Filter as...",
            disabled: !api.canInteract(appState: appState),
            displayMode: .popup
        ) {
            BasicAction(
            id: "personModlogTarget\(id)",
            appearance: .init(label: "Subject", color: .themedAccent, icon: "scope")
            ) {
                navigation.push(.modlog(targetPerson: .init(self), moderatorPerson: nil))
            }
            BasicAction(
            id: "personModlogModerator\(id)",
            appearance: .init(label: "Moderator", color: .themedAccent, icon: Icons.moderation)
            ) {
                navigation.push(.modlog(targetPerson: nil, moderatorPerson: .init(self)))
            }
        }
    }
    
    func banActions(appState: AppState, community: (any Community)?, withUserLabel: Bool = false) -> [any Action] {
        let canBanFromCommunity: Bool
        let showBoth: Bool
        
        let canBanFromInstance = api.isAdmin && api.supports(.banFromInstance, defaultValue: false)
        
        if let myPerson = api.myPerson, let community {
            let supportedByApi = api.supports(.banFromCommunity, defaultValue: false) && (
                apiIsLocal || api.supports(.banFromNonLocalCommunity, defaultValue: false)
            )
            canBanFromCommunity = myPerson.moderates(communityId: community.id) && supportedByApi
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
    
    func banFromCommunityAction(appState: AppState, community: any Community, withUserLabel: Bool = false) -> BasicAction {
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
