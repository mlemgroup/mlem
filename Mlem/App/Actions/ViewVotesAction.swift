//
//  ViewVotesAction.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-25.
//

import Actions
import MlemMiddleware
import SwiftUI

struct ViewVotesAction: SimpleLabelAction {
    let content: VotesListView.Target
}

// MARK: - Configurability

extension ActionSeed {
    static let viewVotes = ActionSeed("viewVotes") { entity in
        switch entity {
        case let entity as Post: ViewVotesAction(content: .post(entity))
        case let entity as Comment: ViewVotesAction(content: .comment(entity))
        default: nil
        }
    }
}

// MARK: - Appearance

extension ViewVotesAction {
    static let label: ActionLabel = .init(
        "View Votes",
        icon: .lemmy.votes,
        color: .themedColorfulAccent(4)
    )
    
    func createLabel(environment: EnvironmentValues) -> ActionLabel {
        Self.label.withVisibility(visibility(environment))
    }
    
    private func visibility(_ environment: EnvironmentValues) -> ActionVisiblity {
        let entity = content.model

        guard entity.api.canInteract(appState: environment.appState) else { return .hidden }
        
        guard let myPerson = entity.api.myPerson else { return .hidden }
        guard let community = entity.community.value else { return .hidden }
        let canModerate = myPerson.moderates(communityId: community.id)
        guard canModerate else { return .hidden }

        guard Settings.get(\.menus_allModActions) || environment.feedContext == .post else { return .hidden }
        guard entity.api.supports(.viewVotes, defaultValue: true) else { return .hidden }

        return .enabled
    }
}

// MARK: - Behavior

extension ViewVotesAction {
    @MainActor
    func execute(environment: EnvironmentValues) {
        environment.navigation?.openSheet(.votesList(content))
    }
}
