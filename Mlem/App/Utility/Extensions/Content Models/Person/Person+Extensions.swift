//
//  Person+Extensions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-02-06.
//

import MlemMiddleware

extension Person {
    var shouldHideInFeed: Bool { blocked || purged }
    
    func flairs(
        interactableContext interactable: (any InteractableProviding)? = nil,
        communityContext community: Community? = nil
    ) -> [PersonFlair] {
        @Setting(\.person_ageVisibility) var alwaysShowAccountAge
        
        let community = community ?? interactable?.community.value
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
            if let creator = interactable.creator.value {
                assert(creator.actorId == actorId)
            } else {
                assertionFailure("No creator!")
            }
            output.formUnion(interactable.contextualFlairs())
        } else {
            if api.myInstance?.administrators.value?.contains(where: { $0.id == id }) ?? false {
                output.insert(.admin)
            }
        }
        
        if let community, community.moderators.value?.contains(where: { $0.id == id }) ?? false {
            output.insert(.moderator)
        }
        
        return output.sorted { $0.sortVal < $1.sortVal }
    }
}
