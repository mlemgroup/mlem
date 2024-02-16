//
//  InteractionBarView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import Dependencies
import Foundation
import SwiftUI

/// View grouping post interactions--upvote, downvote, save, reply, plus post info
struct InteractionBarView: View {
    @Environment(AppState.self) var appState
    
    let content: any InteractableContent
    
    let accessibilityContext: String
    let widgets: [LayoutWidgetType]

    let reply: () -> Void
    
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
            ForEach(Array(widgets.enumerated()), id: \.offset) { offset, widget in
                switch widget {
                case .scoreCounter:
                    ScoreCounterView(
                        vote: content.myVote,
                        score: content.score,
                        upvote: { },
                        downvote: { }
                    )
                
                case .upvoteCounter:
                    if offset == widgets.count - 1 {
                        UpvoteCounterView(vote: content.myVote, score: content.upvoteCount, upvote: { })
                    } else {
                        UpvoteCounterView(vote: content.myVote, score: content.downvoteCount, upvote: { })
                            .padding(.trailing, -AppConstants.postAndCommentSpacing)
                    }
                    
                case .downvoteCounter:
                    // if appState.myInstance?.enableDownvotes ?? false {
                    if offset == widgets.count - 1 {
                        DownvoteCounterView(vote: content.myVote, score: content.downvoteCount, downvote: { })
                    } else {
                        DownvoteCounterView(vote: content.myVote, score: content.downvoteCount, downvote: { })
                            .padding(.trailing, -AppConstants.postAndCommentSpacing)
                    }
                    // }
                    
                case .upvote:
                    UpvoteButtonView(vote: content.myVote, upvote: { })
                    
                case .downvote:
                    // if appState.myInstance?.enableDownvotes ?? false {
                    DownvoteButtonView(vote: content.myVote, downvote: { })
                    // }
                    
                case .save:
                     SaveButtonView(isSaved: content.isSaved, accessibilityContext: accessibilityContext, save: {
//                        Task(priority: .userInitiated) {
//                            await save()
//                        }
                     })
                    
                case .reply:
                    ReplyButtonView(accessibilityContext: accessibilityContext, reply: reply)
                    
                case .share:
                    ShareButtonView(accessibilityContext: accessibilityContext, url: content.actorId)
                    
                case .infoStack:
                    EmptyView()
                    InfoStackView(
                        votes: shouldShowScore
                            ? DetailedVotes(
                                score: content.score,
                                upvotes: content.upvoteCount,
                                downvotes: content.downvoteCount,
                                myVote: content.myVote,
                                showDownvotes: showDownvotesSeparately
                            )
                            : nil,
                        published: shouldShowTime ? content.creationDate : nil,
                        updated: shouldShowTime ? content.updatedDate : nil,
                        commentCount: shouldShowReplies ? content.commentCount : nil,
                        unreadCommentCount: (content as? any Post2Providing)?.unreadCommentCount ?? 0,
                        saved: shouldShowSaved ? content.isSaved : nil,
                        alignment: infoStackAlignment(offset),
                        colorizeVotes: false
                    )
                    .padding(AppConstants.postAndCommentSpacing)
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
            }
        }
        .foregroundStyle(.primary)
        .font(.callout)
    }
}
