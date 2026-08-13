//
//  Post+Actions.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-03.
//

import MlemMiddleware
import Foundation
import os

// Functions to support the old Action system

extension Post {
    func crossPostAction() -> BasicAction {
        .init(
            id: "crosspost\(uid)",
            appearance: .crossPost(),
            callback: {
                var crossPostContent: String
                let crossPostedLabel = String(localized: "Crossposted from \(self.actorId.description)")
                if let content = self.content, !content.isEmpty {
                    crossPostContent = "\(crossPostedLabel)\n-----\n\(content)"
                } else {
                    crossPostContent = crossPostedLabel
                }
                NavigationModel.main.openSheet(.createPost(
                    community: nil,
                    title: self.title,
                    content: crossPostContent,
                    type: self.type,
                    nsfw: self.nsfw,
                    feedLoader: nil
                ))
            }
        )
    }

    // MARK: - Readouts

    func upvoteReadout(showColor: Bool) -> Readout? {
        if let votes = votes.value {
            let isOn = votes.myVote == .upvote
            return Readout(
                id: "upvote\(actorId)",
                label: votes.upvotes.description,
                icon: isOn ? Icons.upvoteSquareFill : Icons.upvoteSquare,
                color: isOn && showColor ? .themedUpvote : nil
            )
        }
        return nil
    }

    func downvoteReadout(showColor: Bool) -> Readout? {
        if let votes = votes.value {
            let isOn = votes.myVote == .downvote
            return Readout(
                id: "downvote\(actorId)",
                label: votes.downvotes.description,
                icon: isOn ? Icons.downvoteSquareFill : Icons.downvoteSquare,
                color: isOn && showColor ? .themedDownvote : nil
            )
        }
        return nil
    }

    func readout(type: ReadoutType, showColor: Bool) -> Readout? {
        switch type {
        case .created: createdReadout
        // swiftlint:disable:next void_function_in_ternary
        case .score: downvotesEnabled ? scoreReadout(showColor: showColor) : upvoteReadout(showColor: showColor)
        case .upvote: upvoteReadout(showColor: showColor)
        case .downvote: downvotesEnabled ? downvoteReadout(showColor: showColor) : nil
        case .comment: commentReadout
        case .saved: savedReadout(showColor: showColor)
        }
    }

    // MARK: - Counters

    func counter(
        appState: AppState,
        type: CounterType,
        commentTreeTracker: CommentTreeTracker? = nil
    ) -> Counter? {
        switch type {
        case .score: scoreCounter(appState: appState, downvotesEnabled: downvotesEnabled)
        case .upvote: upvoteCounter(appState: appState)
        case .downvote: downvotesEnabled ? downvoteCounter(appState: appState, downvotesEnabled: downvotesEnabled) : nil
        case .reply: replyCounter(appState: appState, commentTreeTracker: commentTreeTracker)
        }
    }
}
