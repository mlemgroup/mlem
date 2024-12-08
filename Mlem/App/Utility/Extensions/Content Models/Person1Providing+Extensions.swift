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
        communityContext community: (any Community3Providing)? = nil
    ) -> [PersonFlair] {
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
        
        let intervalSinceCreation = Date.now.timeIntervalSince(created)
        if intervalSinceCreation < 30 * 24 * 60 * 60 {
            output.insert(.new(intervalSinceCreation))
        } else {
            let calendar = Calendar.current
            let createdComponents = calendar.dateComponents([.month, .day], from: created)
            let currentComponents = calendar.dateComponents([.month, .day], from: .now)
            if createdComponents.month == currentComponents.month, createdComponents.day == currentComponents.day {
                output.insert(.cakeDay)
            }
        }
        
        if let interactable {
            assert(interactable.creator.actorId == actorId)
            output.formUnion(interactable.contextualFlairs())
        } else {
            if api.myInstance?.administrators.contains(where: { $0.id == id }) ?? false {
                output.insert(.admin)
            }
        }
        
        if let community, community.moderators.contains(where: { $0.id == id }) {
            output.insert(.moderator)
        }
        
        return output.sorted { $0.sortVal < $1.sortVal }
    }
    
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
                        systemImage: Icons.blockFill,
                        callback: {
                            self.updateBlocked(false)
                        },
                        color: Palette.main.negative
                    )
                )
            } else {
                ToastModel.main.add(
                    .undoable(
                        "Unblocked",
                        systemImage: Icons.unblockFill,
                        callback: {
                            self.updateBlocked(true)
                        },
                        color: Palette.main.primary
                    )
                )
            }
        }
        toggleBlocked()
    }
    
    @ActionBuilder
    func menuActions(
        feedback: Set<FeedbackType> = [.haptic, .toast],
        navigation: NavigationLayer?
    ) -> [any Action] {
        ActionGroup {
            openInstanceAction(navigation: navigation)
            copyNameAction()
            shareAction()
            if (AppState.main.firstSession as? UserSession)?.person?.person1 !== person1 {
                blockAction(feedback: feedback)
            }
        }
        if api.isAdmin {
            ActionGroup {
                banFromInstanceAction()
                purgeAction()
            }
        }
    }
    
    func blockAction(feedback: Set<FeedbackType> = [], showConfirmation: Bool = true) -> BasicAction {
        .init(
            id: "block\(uid)",
            appearance: .block(isOn: blocked),
            callback: api.canInteract ? { self.toggleBlocked(feedback: feedback) } : nil
        )
    }
    
    func banFromInstanceAction() -> BasicAction {
        .init(
            id: "banFromInstance\(uid)",
            appearance: .banFromInstance(isOn: bannedFromInstance),
            callback: api.canInteract && api.isAdmin ? {
                self.showBanSheet(
                    community: nil,
                    isBannedFromCommunity: false,
                    shouldBan: !self.bannedFromInstance
                )
            } : nil
        )
    }
}
