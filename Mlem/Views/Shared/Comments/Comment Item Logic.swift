//
//  Comment Item Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

// swiftlint:disable file_length

import SwiftUI

extension CommentItem {
    // swiftlint:disable:next cyclomatic_complexity
    func enrichLayoutWidgets() -> [EnrichedLayoutWidget] {
        layoutWidgetTracker.groups.comment.compactMap { baseWidget in
            let votes: VotesModel = .init(from: hierarchicalComment.commentView.counts, myVote: hierarchicalComment.commentView.myVote)
            switch baseWidget {
            case .infoStack:
                return .infoStack(
                    colorizeVotes: false,
                    votes: votes,
                    published: hierarchicalComment.commentView.comment.published,
                    updated: hierarchicalComment.commentView.comment.updated,
                    commentCount: hierarchicalComment.commentView.counts.childCount,
                    unreadCommentCount: 0,
                    saved: hierarchicalComment.commentView.saved
                )
            case .upvote:
                return .upvote(myVote: hierarchicalComment.commentView.myVote ?? .resetVote, upvote: upvote)
            case .downvote:
                return .downvote(myVote: hierarchicalComment.commentView.myVote ?? .resetVote, downvote: downvote)
            case .save:
                return .save(saved: hierarchicalComment.commentView.saved, save: saveComment)
            case .reply:
                return .reply(reply: replyToComment)
            case .share:
                if let shareUrl = URL(string: hierarchicalComment.commentView.comment.apId) {
                    return .share(shareUrl: shareUrl)
                } else {
                    return nil
                }
            case .upvoteCounter:
                return .upvoteCounter(votes: votes, upvote: upvote)
            case .downvoteCounter:
                return .downvoteCounter(votes: votes, downvote: downvote)
            case .scoreCounter:
                return .scoreCounter(votes: votes, upvote: upvote, downvote: downvote)
            default:
                return nil
            }
        }
    }
    
    func voteOnComment(inputOp: ScoringOperation) async {
        hapticManager.play(haptic: .lightSuccess, priority: .low)
        let operation = hierarchicalComment.commentView.myVote == inputOp ? ScoringOperation.resetVote : inputOp
        do {
            let updatedComment = try await commentRepository.voteOnComment(
                id: hierarchicalComment.commentView.id,
                vote: operation
            )
            hierarchicalComment.commentView = updatedComment
        } catch {
            errorHandler.handle(error)
        }
    }
    
    func deleteComment() async {
        hapticManager.play(haptic: .success, priority: .low)
        let comment = hierarchicalComment.commentView.comment
        do {
            let updatedComment = try await commentRepository.deleteComment(
                id: comment.id,
                // TODO: the UI for this only allows delete, but the operation can be undone it appears...
                shouldDelete: true
            )
            hierarchicalComment.commentView = updatedComment.commentView
        } catch {
            errorHandler.handle(error)
        }
    }
    
    func upvote() async {
        // don't do anything if currently awaiting a vote response
        guard dirty else {
            // fake downvote
            switch displayedVote {
            case .upvote:
                dirtyVote = .resetVote
                dirtyScore = displayedScore - 1
            case .resetVote:
                dirtyVote = .upvote
                dirtyScore = displayedScore + 1
            case .downvote:
                dirtyVote = .upvote
                dirtyScore = displayedScore + 2
            }
            dirty = true

            // wait for vote
            await voteOnComment(inputOp: .upvote)

            // unfake downvote and restore state
            dirty = false
            return
        }
    }

    func downvote() async {
        // don't do anything if currently awaiting a vote response
        guard dirty else {
            // fake upvote
            switch displayedVote {
            case .upvote:
                dirtyVote = .downvote
                dirtyScore = displayedScore - 2
            case .resetVote:
                dirtyVote = .downvote
                dirtyScore = displayedScore - 1
            case .downvote:
                dirtyVote = .resetVote
                dirtyScore = displayedScore + 1
            }
            dirty = true

            // wait for vote
            await voteOnComment(inputOp: .downvote)

            // unfake upvote
            dirty = false
            return
        }
    }
    
    func replyToComment() {
        editorTracker.openEditor(with: ConcreteEditorModel(
            comment: hierarchicalComment.commentView,
            commentTracker: commentTracker,
            operation: CommentOperation.replyToComment
        ))
    }

    func editComment() {
        editorTracker.openEditor(with: ConcreteEditorModel(
            comment: hierarchicalComment.commentView,
            commentTracker: commentTracker,
            operation: CommentOperation.editComment
        ))
    }
    
    /// Asynchronous wrapper around replyToComment so that it can be used in swipey actions
    func replyToCommentAsyncWrapper() async {
        replyToComment()
    }

    /// Sends a save request for the current post
    func saveComment() async {
        guard !dirty else {
            return
        }
        
        defer { dirty = false }
        dirty = true
        dirtySaved.toggle()
        
        hapticManager.play(haptic: .success, priority: .low)
        
        do {
            let response = try await commentRepository.saveComment(
                id: hierarchicalComment.id,
                shouldSave: dirtySaved
            )
            
            hierarchicalComment.commentView = response.commentView
        } catch {
            errorHandler.handle(error)
        }
    }
    
    func toggleCollapsed() {
        withAnimation(.showHideComment(!hierarchicalComment.isCollapsed)) {
            // Perhaps we want an explict flag for this in the future?
            if collapseComments, !isCommentReplyHidden, pageContext == .posts, hierarchicalComment.depth == 0 {
                toggleTopLevelCommentCollapse(isCollapsed: !hierarchicalComment.isCollapsed)
            } else if !showPostContext, let commentTracker {
                commentTracker.setCollapsed(!hierarchicalComment.isCollapsed, comment: hierarchicalComment)
            }
        }
    }
    
    /// Uncollapses HierarchicalComment and children at depth level 1
    func uncollapseComment() {
        if let commentTracker {
            commentTracker.setCollapsed(false, comment: hierarchicalComment)
            
            for comment in hierarchicalComment.children where comment.depth == 1 {
                commentTracker.setCollapsed(false, comment: comment)
            }
        }
    }
    
    // Collapses the top level comment and retains the child comment collapse state
    // If a user views all child comments, then collapses top level comment, the children will be uncollapsed along side top level
    func toggleTopLevelCommentCollapse(isCollapsed: Bool) {
        hierarchicalComment.isCollapsed = isCollapsed
        
        if !isCollapsed {
            isCommentReplyHidden = false
        }
    }
    
    /// Collapses HierarchicalComment and children at depth level 1
    func collapseComment() {
        if let commentTracker {
            for comment in hierarchicalComment.children where comment.depth == 1 {
                commentTracker.setCollapsed(true, comment: comment)
                comment.isParentCollapsed = true
            }
        }
    }
    
    // MARK: helpers
    
    func blockUser(userId: Int) async {
        do {
            let response = try await apiClient.blockPerson(id: userId, shouldBlock: true)
            
            if response.blocked {
                await notifier.add(.success("Blocked user"))
                
                if let commentTracker {
                    commentTracker.filter { comment in
                        comment.commentView.creator.id != userId
                    }
                }
            }
        } catch {
            errorHandler.handle(
                .init(
                    message: "Unable to block user",
                    style: .toast,
                    underlyingError: error
                )
            )
        }
    }
}

// swiftlint:enable file_length
