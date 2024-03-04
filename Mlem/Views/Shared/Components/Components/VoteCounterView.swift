//
//  Standard Vote Complex.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Foundation
import SwiftUI

struct VoteCounterView: View {
    let content: any InteractableContent
    let voteType: ScoringOperation
    
    var isOn: Bool {
        content.source.api.token != nil && content.myVote == voteType
    }
    
    init(content: any InteractableContent, voteType: ScoringOperation) {
        self.content = content
        if voteType == .none {
            assertionFailure("VoteCounterView cannot accept .none")
        }
        self.voteType = voteType
    }

    var body: some View {
        HStack(spacing: 6) {
            VoteButtonView(content: content, voteType: voteType)
            
            Text(String(voteType == .upvote ? content.upvoteCount : content.downvoteCount))
                .foregroundColor(isOn ? voteType.color! : .primary)
                .monospacedDigit()
        }
    }
}