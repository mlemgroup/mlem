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
    
    // swiftlint:disable function_body_length
    func genMenuFunctions() -> [MenuFunction] {
        let isMod = siteInformation.isModOrAdmin(communityId: hierarchicalComment.commentView.post.communityId)
        
        var ret: [MenuFunction] = .init()
        
        var mainFunctions: [MenuFunction] = .init()
        // upvote
        let (upvoteText, upvoteImg) = hierarchicalComment.commentView.myVote == .upvote ?
        ("Undo Upvote", Icons.upvoteSquareFill) :
        ("Upvote", Icons.upvoteSquare)
        mainFunctions.append(MenuFunction.standardMenuFunction(
            text: upvoteText,
            imageName: upvoteImg
        ) {
            Task(priority: .userInitiated) {
                await upvote()
            }
        })
        
        // downvote
        let (downvoteText, downvoteImg) = hierarchicalComment.commentView.myVote == .downvote ?
        ("Undo Downvote", Icons.downvoteSquareFill) :
        ("Downvote", Icons.downvoteSquare)
        mainFunctions.append(MenuFunction.standardMenuFunction(
            text: downvoteText,
            imageName: downvoteImg
        ) {
            Task(priority: .userInitiated) {
                await downvote()
            }
        })
                
        // save
        let (saveText, saveImg) = hierarchicalComment.commentView.saved ?
        ("Unsave", Icons.saveFill) :
        ("Save", Icons.save)
        mainFunctions.append(MenuFunction.standardMenuFunction(
            text: saveText,
            imageName: saveImg
        ) {
            Task(priority: .userInitiated) {
                await saveComment()
            }
        })

        // reply
        mainFunctions.append(MenuFunction.standardMenuFunction(
            text: "Reply",
            imageName: Icons.reply
        ) {
            replyToComment()
        })
        
        let content = self.hierarchicalComment.commentView.comment.content
        mainFunctions.append(MenuFunction.standardMenuFunction(
            text: "Select Text",
            imageName: Icons.select
        ) {
            editorTracker.openEditor(with: SelectTextModel(text: content))
        })
        
        let isOwnComment = appState.isCurrentAccountId(hierarchicalComment.commentView.creator.id)
        
        if isOwnComment {
            // edit
            mainFunctions.append(MenuFunction.standardMenuFunction(
                text: "Edit",
                imageName: Icons.edit
            ) {
                editComment()
            })
        
            // delete
            mainFunctions.append(MenuFunction.standardMenuFunction(
                text: "Delete",
                imageName: Icons.delete,
                confirmationPrompt: "Are you sure you want to delete this comment?  This cannot be undone.",
                enabled: !hierarchicalComment.commentView.comment.deleted
            ) {
                Task(priority: .userInitiated) {
                    await deleteComment()
                }
            })
        }
                
        // share
        if let url = URL(string: hierarchicalComment.commentView.comment.apId) {
            mainFunctions.append(MenuFunction.shareMenuFunction(url: url))
        }
        
        if !isOwnComment {
            if !isMod {
                // report
                mainFunctions.append(MenuFunction.standardMenuFunction(
                    text: "Report",
                    imageName: Icons.moderationReport,
                    confirmationPrompt: AppConstants.reportCommentPrompt
                ) {
                    editorTracker.openEditor(with: ConcreteEditorModel(
                        comment: hierarchicalComment.commentView,
                        operation: CommentOperation.reportComment
                    ))
                })
            }
            
            // block
            mainFunctions.append(MenuFunction.standardMenuFunction(
                text: "Block User",
                imageName: Icons.hide,
                confirmationPrompt: AppConstants.blockUserPrompt
            ) {
                Task(priority: .userInitiated) {
                    await blockUser(userId: hierarchicalComment.commentView.creator.id)
                }
            })
        }
        
        ret.append(.controlGroupMenuFunction(children: mainFunctions))
        
        if isMod, !isOwnComment {
            ret.append(.divider)
            ret.append(MenuFunction.toggleableMenuFunction(
                toggle: hierarchicalComment.commentView.comment.removed,
                trueText: "Restore",
                trueImageName: Icons.restore,
                falseText: "Remove",
                falseImageName: Icons.remove,
                isDestructive: .always
            ) {
                modToolTracker.removeComment(
                    hierarchicalComment,
                    shouldRemove: !self.hierarchicalComment.commentView.comment.removed
                )
            })
            
            let creatorBannedFromCommunity = hierarchicalComment.commentView.creatorBannedFromCommunity
            let creatorBannedFromInstance = hierarchicalComment.commentView.creator.banned
            
            if !(siteInformation.isAdmin && creatorBannedFromCommunity && creatorBannedFromInstance) {
                ret.append(MenuFunction.toggleableMenuFunction(
                    toggle: creatorBannedFromCommunity,
                    trueText: "Unban User",
                    trueImageName: Icons.communityUnban,
                    falseText: "Ban User",
                    falseImageName: (siteInformation.isAdmin && !creatorBannedFromInstance) ? Icons.instanceBan : Icons.communityBan,
                    isDestructive: .whenFalse
                ) {
                    modToolTracker.banUserFromCommunity(
                        .init(from: hierarchicalComment.commentView.creator),
                        from: .init(from: hierarchicalComment.commentView.community),
                        bannedFromCommunity: creatorBannedFromCommunity,
                        shouldBan: !creatorBannedFromCommunity,
                        postTracker: nil,
                        commentTracker: commentTracker
                    )
                })
            }
            
            if siteInformation.isAdmin, creatorBannedFromInstance || creatorBannedFromCommunity {
                ret.append(MenuFunction.toggleableMenuFunction(
                    toggle: creatorBannedFromInstance,
                    trueText: "Unban User",
                    trueImageName: Icons.instanceUnban,
                    falseText: "Ban User",
                    falseImageName: Icons.instanceBan,
                    isDestructive: .whenFalse
                ) {
                    modToolTracker.banUserFromCommunity(
                        .init(from: hierarchicalComment.commentView.creator),
                        from: .init(from: hierarchicalComment.commentView.community),
                        bannedFromCommunity: creatorBannedFromCommunity,
                        shouldBan: !creatorBannedFromInstance,
                        postTracker: nil,
                        commentTracker: commentTracker
                    )
                })
            }
        }
                   
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
