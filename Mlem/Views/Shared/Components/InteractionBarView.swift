//
//  InteractionBarView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import Dependencies
import Foundation
import SwiftUI

/**
 View grouping post interactions--upvote, downvote, save, reply, plus post info
 */
struct InteractionBarView: View {
    @Dependency(\.siteInformation) var siteInformation
    
    // environment
    @EnvironmentObject var commentTracker: CommentTracker
    
    // metadata
    let votes: VotesModel
    let published: Date
    let numReplies: Int
    let saved: Bool
    
    let accessibilityContext: String
    let widgets: [LayoutWidgetType]

    let upvote: () async -> Void
    let downvote: () async -> Void
    let save: () async -> Void
    let reply: () -> Void
    let share: () -> Void
    
    var shouldShowScore: Bool = true
    var showDownvotesSeparately: Bool = false
    var shouldShowTime: Bool = true
    var shouldShowSaved: Bool = false
    var shouldShowReplies: Bool = true
    
    func infoStackAlignment(_ offset: Int) -> HorizontalAlignment {
        if offset == 0 {
            return .leading
        } else if offset == widgets.count - 1 {
            return .trailing
        }
        return .center
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(widgets.enumerated()), id: \.element) { offset, widget in
                switch widget {
                case .scoreCounter:
                    ScoreCounterView(
                        vote: votes.myVote,
                        score: votes.total,
                        upvote: upvote,
                        downvote: downvote
                    )
                
                case .upvoteCounter:
                    if offset == widgets.count - 1 {
                        UpvoteCounterView(vote: votes.myVote, score: votes.upvotes, upvote: upvote)
                    } else {
                        UpvoteCounterView(vote: votes.myVote, score: votes.upvotes, upvote: upvote)
                            .padding(.trailing, -AppConstants.postAndCommentSpacing)
                    }
                    
                case .downvoteCounter:
                    if siteInformation.enableDownvotes {
                        if offset == widgets.count - 1 {
                            DownvoteCounterView(vote: votes.myVote, score: votes.downvotes, downvote: downvote)
                        } else {
                            DownvoteCounterView(vote: votes.myVote, score: votes.downvotes, downvote: downvote)
                                .padding(.trailing, -AppConstants.postAndCommentSpacing)
                        }
                    }
                    
                case .upvote:
                    UpvoteButtonView(vote: votes.myVote, upvote: upvote)
                    
                case .downvote:
                    if siteInformation.enableDownvotes {
                        DownvoteButtonView(vote: votes.myVote, downvote: downvote)
                    }
                    
                case .save:
                    SaveButtonView(isSaved: saved, accessibilityContext: accessibilityContext, save: {
                        Task(priority: .userInitiated) {
                            await save()
                        }
                    })
                    
                case .reply:
                    ReplyButtonView(accessibilityContext: accessibilityContext, reply: reply)
                    
                case .share:
                    ShareButtonView(accessibilityContext: accessibilityContext, share: share)
                    
                case .infoStack:
                    InfoStackView(
                        votes: shouldShowScore
                            ? DetailedVotes(
                                score: votes.total,
                                upvotes: votes.upvotes,
                                downvotes: votes.downvotes,
                                myVote: votes.myVote,
                                showDownvotes: showDownvotesSeparately
                            )
                            : nil,
                        published: shouldShowTime ? published : nil,
                        commentCount: shouldShowReplies ? numReplies : nil,
                        saved: shouldShowSaved ? saved : nil,
                        alignment: infoStackAlignment(offset)
                    )
                    .padding(AppConstants.postAndCommentSpacing)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .foregroundStyle(.primary)
        .font(.callout)
    }
}
