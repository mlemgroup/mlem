//
//  Comment Item Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import SwiftUI

extension CommentItem {
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
            if collapseComments, !isCommentReplyHidden, pageContext == .posts {
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
    
    // swiftlint:disable function_body_length
    func genMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // upvote
        let (upvoteText, upvoteImg) = hierarchicalComment.commentView.myVote == .upvote ?
            ("Undo Upvote", Icons.upvoteSquareFill) :
            ("Upvote", Icons.upvoteSquare)
        ret.append(MenuFunction.standardMenuFunction(
            text: upvoteText,
            imageName: upvoteImg,
            role: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await upvote()
            }
        })
        
        // downvote
        let (downvoteText, downvoteImg) = hierarchicalComment.commentView.myVote == .downvote ?
            ("Undo Downvote", Icons.downvoteSquareFill) :
            ("Downvote", Icons.downvoteSquare)
        ret.append(MenuFunction.standardMenuFunction(
            text: downvoteText,
            imageName: downvoteImg,
            role: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await downvote()
            }
        })
        
        // save
        let (saveText, saveImg) = hierarchicalComment.commentView.saved ?
            ("Unsave", Icons.unsave) :
            ("Save", Icons.save)
        ret.append(MenuFunction.standardMenuFunction(
            text: saveText,
            imageName: saveImg,
            role: nil,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await saveComment()
            }
        })
        
        // reply
        ret.append(MenuFunction.standardMenuFunction(
            text: "Reply",
            imageName: Icons.reply,
            role: nil,
            enabled: true
        ) {
            replyToComment()
        })
        
        // edit
        if appState.isCurrentAccountId(hierarchicalComment.commentView.creator.id) {
            ret.append(MenuFunction.standardMenuFunction(
                text: "Edit",
                imageName: Icons.edit,
                role: nil,
                enabled: true
            ) {
                editComment()
            })
        }
        
        // delete
        if appState.isCurrentAccountId(hierarchicalComment.commentView.creator.id) {
            ret.append(MenuFunction.standardMenuFunction(
                text: "Delete",
                imageName: Icons.delete,
                role: .destructive(prompt: "Are you sure you want to delete this comment?  This cannot be undone."),
                enabled: !hierarchicalComment.commentView.comment.deleted
            ) {
                Task(priority: .userInitiated) {
                    await deleteComment()
                }
            })
        }
        
        // share
        if let url = URL(string: hierarchicalComment.commentView.comment.apId) {
            ret.append(MenuFunction.shareMenuFunction(url: url))
        }
        
        // report
        ret.append(MenuFunction.standardMenuFunction(
            text: "Report",
            imageName: Icons.moderationReport,
            role: .destructive(prompt: "Really report?"),
            enabled: true
        ) {
            editorTracker.openEditor(with: ConcreteEditorModel(
                comment: hierarchicalComment.commentView,
                operation: CommentOperation.reportComment
            ))
        })
        
        // block
        ret.append(MenuFunction.standardMenuFunction(
            text: "Block User",
            imageName: Icons.userBlock,
            role: .destructive(prompt: AppConstants.blockUserPrompt),
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await blockUser(userId: hierarchicalComment.commentView.creator.id)
            }
        })
                   
        return ret
    }

    // swiftlint:enable function_body_length
    
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
