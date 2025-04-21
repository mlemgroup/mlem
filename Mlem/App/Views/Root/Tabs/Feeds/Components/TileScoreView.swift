//
//  TileScoreView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-19.
//

import Foundation
import MlemMiddleware
import SwiftUI

struct TileScoreView: View {
    let saved: Bool
    let votes: VotesModel
    
    var body: some View {
        Group {
            postTag(active: saved, icon: .lemmy.saved, color: .themedSave) + // saved status
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

extension TileScoreView {
    init(_ interactable: any Interactable2Providing) {
        self.saved = interactable.saved
        self.votes = interactable.votes
    }
}
