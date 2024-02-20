//
//  VoteButtonView.swift
//  Mlem
//
//  Created by David Bureš on 25.03.2022.
//

import Dependencies
import SwiftUI

struct VoteButtonView: View {
    @Dependency(\.hapticManager) var hapticManager
    
    let content: any InteractableContent
    let voteType: ScoringOperation
    
    init(content: any InteractableContent, voteType: ScoringOperation) {
        self.content = content
        if voteType == .none {
            assertionFailure("VoteButtonView cannot accept .none")
        }
        self.voteType = voteType
    }

    var body: some View {
        Button {
            hapticManager.play(haptic: .lightSuccess, priority: .low)
            Task(priority: .userInitiated) {
                try await content.vote(voteType == content.myVote ? .none : voteType)
            }
        } label: {
            Image(systemName: voteType.buttonIconName)
                .resizable()
                .scaledToFit()
                .frame(width: AppConstants.barIconSize, height: AppConstants.barIconSize)
                .padding(AppConstants.barIconPadding)
                .foregroundColor(content.myVote == voteType ? .white : .primary)
                .background(RoundedRectangle(cornerRadius: AppConstants.tinyItemCornerRadius)
                .aspectRatio(1, contentMode: .fit)
                .foregroundColor(content.myVote == voteType ? voteType.color! : .clear))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
}
