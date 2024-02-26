//
//  ScoreCounterView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-13.
//

import Dependencies
import Foundation
import SwiftUI

struct ScoreCounterView: View {
    @Dependency(\.hapticManager) var hapticManager
    
    let content: any InteractableContent

    var body: some View {
        HStack(spacing: 6) {
            VoteButtonView(content: content, voteType: .upvote)
            
            Text(String(content.score))
                .foregroundColor(content.myVote.color ?? .primary)
                .monospacedDigit()
            
            // if siteInformation.enableDownvotes {
            VoteButtonView(content: content, voteType: .downvote)
            // }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                Task(priority: .userInitiated) {
                    hapticManager.play(haptic: .lightSuccess, priority: .low)
                    try await content.toggleUpvote()
                }
            case .decrement:
                Task(priority: .userInitiated) {
                    hapticManager.play(haptic: .lightSuccess, priority: .low)
                    try await content.toggleDownvote()
                }
            default:
                // Not sure what to do here.
                UIAccessibility.post(notification: .announcement, argument: "Unknown Action")
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}
