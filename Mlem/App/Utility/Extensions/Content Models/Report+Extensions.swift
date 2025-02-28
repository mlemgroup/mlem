//
//  Report+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-16.
//

import MlemMiddleware

extension Report {
    func toggleResolved(feedback: Set<FeedbackType>) {
        if feedback.contains(.haptic) {
            HapticManager.main.play(haptic: .success, priority: .low)
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
        
        if let community = target.community, myPerson.moderates(communityId: community.id) {
            return target.creator.banFromCommunityAction(appState: appState, community: community)
        }
        
        return target.creator.banFromInstanceAction(appState: appState)
    }
}
