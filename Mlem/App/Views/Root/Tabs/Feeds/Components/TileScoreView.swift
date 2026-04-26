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
                Text(Image(systemName: votes.iconName)) + // vote status
                Text(verbatim: " \(votes.total.abbreviated)")
            }
            .lineLimit(1)
            .font(.caption)
            .foregroundStyle(votes.iconColor)
            .contentShape(.rect)
        }
    }
}

extension TileScoreView {
    init(_ interactable: any InteractableProviding) {
        self.saved = interactable.saved
        self.votes = interactable.votes
    }
}
