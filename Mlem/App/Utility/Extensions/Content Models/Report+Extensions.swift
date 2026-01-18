//
//  Report+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-16.
//

import Haptics
import MlemMiddleware

extension Report {
    func toggleResolved(feedback: Set<FeedbackType>) {
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .success, tier: .low)
        }
        toggleResolved()
    }
    
    @ActionBuilder
    func menuActions(
        appState: AppState,
        feedback: Set<FeedbackType> = [.haptic]
    ) -> [any Action] {
        resolveAction(appState: appState, feedback: feedback)
    }
    
    func resolveAction(appState: AppState, feedback: Set<FeedbackType> = []) -> BasicAction {
        .init(
            id: "resolve\(cacheId)",
            appearance: .resolve(isOn: resolved),
            callback: api.canInteract(appState: appState) ? { @MainActor in self.toggleResolved(feedback: feedback) } : nil
        )
    }
    
    func contextualBanAction(appState: AppState) -> BasicAction? {
        guard let myPerson = api.myPerson else { return nil }
        
        if let community = target.community, let creator = target.creator.value, myPerson.moderates(communityId: community.id) {
            return creator.banFromCommunityAction(appState: appState, community: community)
        }
        
        return target.creator.value?.banFromInstanceAction(appState: appState)
    }
}
