//
//  TileScoreView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-19.
//

import Foundation
import MlemMiddleware
import SwiftUI
import Icons

struct TileScoreView: View {
    let saved: ExpectedValue<Bool>
    let votes: ExpectedValue<VotesModel>
    
    var body: some View {
        if let saved = saved.value, let votes = votes.value {
            Group {
                postTag(active: saved, icon: .lemmy.saved.representingState(active: true), color: .themedSave) + // saved status
                Text(verbatim: saved ? " " : "") + // spacing after save
                Text(Image(icon: voteIcon(votes))) + // vote status
                Text(verbatim: " \(votes.total.abbreviated)")
            }
            .lineLimit(1)
            .font(.caption)
            .foregroundStyle(votes.color)
            .contentShape(.rect)
        }
    }
    
    func voteIcon(_ votes: VotesModel) -> Icon {
        if votes.myVote == .none {
            return ScoringOperation.upvote.icon.representingState(active: false)
        }
        return votes.myVote.icon.representingState(active: true)
    }
}

extension TileScoreView {
    init(_ interactable: any InteractableProviding) {
        self.saved = interactable.saved
        self.votes = interactable.votes
    }
}
