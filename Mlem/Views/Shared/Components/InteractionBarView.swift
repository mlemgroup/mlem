//
//  InteractionBarView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-10.
//

import Dependencies
import Foundation
import SwiftUI

enum InteractionBarContext {
    case post, comment
    
    var accessibilityLabel: String {
        switch self {
        case .post:
            "post"
        case .comment:
            "comment"
        }
    }
}

/// View grouping post interactions--upvote, downvote, save, reply, plus post info
struct InteractionBarView: View {
    // post
    @AppStorage("showDownvotesSeparately") var showPostDownvotesSeparately: Bool = false
    @AppStorage("shouldShowScoreInPostBar") var shouldShowScoreInPostBar: Bool = false
    @AppStorage("shouldShowTimeInPostBar") var shouldShowTimeInPostBar: Bool = true
    @AppStorage("shouldShowSavedInPostBar") var shouldShowSavedInPostBar: Bool = false
    @AppStorage("shouldShowRepliesInPostBar") var shouldShowRepliesInPostBar: Bool = true
    
    // comment
    @AppStorage("showCommentDownvotesSeparately") var showCommentDownvotesSeparately: Bool = false
    @AppStorage("shouldShowScoreInCommentBar") var shouldShowScoreInCommentBar: Bool = false
    @AppStorage("shouldShowTimeInCommentBar") var shouldShowTimeInCommentBar: Bool = true
    @AppStorage("shouldShowSavedInCommentBar") var shouldShowSavedInCommentBar: Bool = false
    @AppStorage("shouldShowRepliesInCommentBar") var shouldShowRepliesInCommentBar: Bool = true
    
    @Dependency(\.siteInformation) var siteInformation
    
    // environment
    @EnvironmentObject var commentTracker: CommentTracker
    
    let context: InteractionBarContext
    let widgets: [EnrichedLayoutWidget]
    
    init(
        context: InteractionBarContext,
        widgets: [EnrichedLayoutWidget]
    ) {
        self.context = context
        self.widgets = widgets
    }
    
    // MARK: Info Stack stuff
    
    func detailedVotes(from votes: VotesModel) -> DetailedVotes? {
        let (showScore, showDownvotesSeparately): (Bool, Bool) = {
            switch context {
            case .post:
                (shouldShowScoreInPostBar, showPostDownvotesSeparately)
            case .comment:
                (shouldShowScoreInCommentBar, showCommentDownvotesSeparately)
            }
        }()
        
        if showScore {
            return .init(
                score: votes.total,
                upvotes: votes.upvotes,
                downvotes: votes.downvotes,
                myVote: votes.myVote,
                showDownvotes: showDownvotesSeparately
            )
        }
        
        return nil
    }
    
    var showPublished: Bool {
        switch context {
        case .post:
            shouldShowTimeInPostBar
        case .comment:
            shouldShowTimeInCommentBar
        }
    }
    
    var showSaved: Bool {
        switch context {
        case .post:
            shouldShowSavedInPostBar
        case .comment:
            shouldShowSavedInCommentBar
        }
    }
    
    var showReplies: Bool {
        switch context {
        case .post:
            shouldShowRepliesInPostBar
        case .comment:
            shouldShowRepliesInCommentBar
        }
    }
    
    func infoStackAlignment(_ offset: Int) -> HorizontalAlignment {
        if offset == 0 {
            return .leading
        } else if offset == widgets.count - 1 {
            return .trailing
        }
        return .center
    }
    
    // MARK: Rendering
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(widgets.enumerated()), id: \.offset) { offset, widget in
                buildWidget(for: widget, offset: offset)
            }
        }
        .foregroundStyle(.primary)
        .font(.callout)
    }
    
    // swiftlint:disable cyclomatic_complexity function_body_length
    @ViewBuilder
    func buildWidget(for widget: EnrichedLayoutWidget, offset: Int) -> some View {
        switch widget {
        case let .upvote(myVote, upvote):
            UpvoteButtonView(vote: myVote, upvote: upvote)
        case let .downvote(myVote, downvote):
            DownvoteButtonView(vote: myVote, downvote: downvote)
        case let .save(saved, save):
            SaveButtonView(isSaved: saved, accessibilityContext: context.accessibilityLabel, save: save)
        case let .reply(reply):
            ReplyButtonView(accessibilityContext: context.accessibilityLabel, reply: reply)
        case let .share(shareUrl):
            ShareButtonView(accessibilityContext: context.accessibilityLabel, url: shareUrl)
        case let .upvoteCounter(votes, upvote):
            if offset == widgets.count - 1 {
                UpvoteCounterView(vote: votes.myVote, score: votes.upvotes, upvote: upvote)
            } else {
                UpvoteCounterView(vote: votes.myVote, score: votes.upvotes, upvote: upvote)
                    .padding(.trailing, -AppConstants.standardSpacing)
            }
        case let .downvoteCounter(votes, downvote):
            if siteInformation.enableDownvotes {
                if offset == widgets.count - 1 {
                    DownvoteCounterView(vote: votes.myVote, score: votes.downvotes, downvote: downvote)
                } else {
                    DownvoteCounterView(vote: votes.myVote, score: votes.downvotes, downvote: downvote)
                        .padding(.trailing, -AppConstants.standardSpacing)
                }
            }
        case let .scoreCounter(votes, upvote, downvote):
            ScoreCounterView(
                vote: votes.myVote,
                score: votes.total,
                upvote: upvote,
                downvote: downvote
            )
        case let .resolve(resolved, resolve):
            ResolveButtonView(resolved: resolved, resolve: resolve)
        case let .remove(removed, remove):
            RemoveButtonView(removed: removed, remove: remove)
        case .purge:
            PurgeButtonView()
        case let .ban(banned, ban):
            BanButtonView(banned: banned, ban: ban)
        case let .infoStack(colorizeVotes, votes, published, updated, commentCount, unreadCommentCount, saved):
            InfoStackView(
                votes: detailedVotes(from: votes),
                published: showPublished ? published : nil,
                updated: updated,
                commentCount: showReplies ? commentCount : nil,
                unreadCommentCount: unreadCommentCount,
                saved: showSaved ? saved : nil,
                alignment: infoStackAlignment(offset),
                colorizeVotes: colorizeVotes
            )
            .padding(AppConstants.standardSpacing)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
}
