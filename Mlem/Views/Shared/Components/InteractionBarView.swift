//
//  Comment Interaction Bar.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import SwiftUI

import Foundation

/**
 View grouping post interactions--upvote, downvote, save, reply, plus post info
 */
struct InteractionBarView: View {
    // environment
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var commentTracker: CommentTracker
    
    // parameters
    let apiView: any APIContentViewProtocol
    let accessibilityContext: String
    let widgets: [LayoutWidgetType]
    let displayedScore: Int
    let displayedVote: ScoringOperation
    let displayedSaved: Bool

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
                                vote: displayedVote,
                                score: displayedScore,
                                upvote: upvote,
                                downvote: downvote
                    )
                
                case .upvoteCounter:
                    if offset == widgets.count - 1 {
                        UpvoteCounterView(vote: displayedVote, score: apiView.counts.upvotes, upvote: upvote)
                    } else {
                        UpvoteCounterView(vote: displayedVote, score: apiView.counts.upvotes, upvote: upvote)
                            .padding(.trailing, -AppConstants.postAndCommentSpacing)
                    }
                    
                case .downvoteCounter:
                    if appState.enableDownvote {
                        if offset == widgets.count - 1 {
                            DownvoteCounterView(vote: displayedVote, score: apiView.counts.downvotes, downvote: downvote)
                        } else {
                            DownvoteCounterView(vote: displayedVote, score: apiView.counts.downvotes, downvote: downvote)
                                .padding(.trailing, -AppConstants.postAndCommentSpacing)
                        }
                    }
                    
                case .upvote:
                     UpvoteButtonView(vote: displayedVote, upvote: upvote)
                    
                case .downvote:
                    if appState.enableDownvote {
                       DownvoteButtonView(vote: displayedVote, downvote: downvote)
                    }
                    
                case .save:
                    SaveButtonView(isSaved: displayedSaved, accessibilityContext: accessibilityContext, save: {
                        Task(priority: .userInitiated) {
                            await save()
                        }
                    })
                    
                case .reply:
                    ReplyButtonView(accessibilityContext: accessibilityContext, reply: reply)
                    
                case .share:
                    ShareButtonView(accessibilityContext: accessibilityContext, share: share)
                    
                case .infoStack:
                    InfoStackView(votes: shouldShowScore
                              ? DetailedVotes(score: displayedScore,
                                              upvotes: apiView.counts.upvotes,
                                              downvotes: apiView.counts.downvotes,
                                              myVote: apiView.myVote ?? .resetVote,
                                              showDownvotes: showDownvotesSeparately)
                              : nil,
                              published: shouldShowTime ? apiView.counts.published : nil,
                              commentCount: shouldShowReplies ? apiView.counts.comments : nil,
                              saved: shouldShowSaved ? apiView.saved : nil,
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
