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
        HStack(spacing: AppConstants.postAndCommentSpacing) {
            ForEach(Array(widgets.enumerated()), id: \.offset) { offset, widget in
                switch widget {
                case .scoreCounter:
                    ScoreCounterView(content: content)
                
                case .upvoteCounter:
                    VoteCounterView(content: content, voteType: .upvote)

                case .downvoteCounter:
                    // if appState.myInstance?.enableDownvotes ?? false {
                    VoteCounterView(content: content, voteType: .downvote)
                    // }
                    
                case .upvote:
                    VoteButtonView(content: content, voteType: .upvote)
                    
                case .downvote:
                    // if appState.myInstance?.enableDownvotes ?? false {
                    VoteButtonView(content: content, voteType: .downvote)
                    // }
                    
                case .save:
                    SaveButtonView(content: content, accessibilityContext: accessibilityContext)
                    
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
                    .padding(.vertical, AppConstants.postAndCommentSpacing)
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
            }
        }
        .foregroundStyle(.primary)
        .font(.callout)
        .padding(.vertical, 4)
    }
}
