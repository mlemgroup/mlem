//
//  Comment Item Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-20.
//

import SwiftUI

extension CommentItem {
    func voteOnComment(inputOp: ScoringOperation) async {
        let operation = hierarchicalComment.commentModel.votes.myVote == inputOp ? ScoringOperation.resetVote : inputOp
        
        // update comments locally (fake state)
        let newVotes = hierarchicalComment.commentModel.votes.applyScoringOperation(operation: operation)
        commentTracker.comments.update(with: CommentModel(comment: hierarchicalComment.commentModel.comment,
                                                          creator: hierarchicalComment.commentModel.creator,
                                                          post: hierarchicalComment.commentModel.post,
                                                          community: hierarchicalComment.commentModel.community,
                                                          votes: newVotes,
                                                          numReplies: hierarchicalComment.commentModel.numReplies,
                                                          published: hierarchicalComment.commentModel.published,
                                                          updated: hierarchicalComment.commentModel.updated,
                                                          saved: hierarchicalComment.commentModel.saved))
        
        do {
            let updatedComment = try await commentRepository.voteOnComment(
                id: hierarchicalComment.commentModel.comment.id,
                vote: operation
            )
            commentTracker.comments.update(with: CommentModel(from: updatedComment))
        } catch {
            errorHandler.handle(
                .init(underlyingError: error)
            )
        }
    }
    
    func deleteComment() async {
        let comment = hierarchicalComment.commentModel.comment
        do {
            let updatedComment = try await commentRepository.deleteComment(
                id: comment.id,
                // TODO: the UI for this only allows delete, but the operation can be undone it appears...
                shouldDelete: true
            )
            commentTracker.comments.update(with: updatedComment.commentModel)
        } catch {
            errorHandler.handle(
                .init(underlyingError: error)
            )
        }
    }
    
    func upvote() async {
        await voteOnComment(inputOp: .upvote)
    }

    func downvote() async {
        // don't do anything if currently awaiting a vote response
        await voteOnComment(inputOp: .downvote)
    }
    
    func replyToComment() {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           comment: hierarchicalComment.commentModel,
                                                           commentTracker: commentTracker,
                                                           operation: CommentOperation.replyToComment))
    }

    func editComment() {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           comment: hierarchicalComment.commentModel,
                                                           commentTracker: commentTracker,
                                                           operation: CommentOperation.editComment))
    }
    
    /**
     Asynchronous wrapper around replyToComment so that it can be used in swipey actions
     */
    func replyToCommentAsyncWrapper() async {
        replyToComment()
    }

    /**
     Sends a save request for the current post
     */
    func saveComment() async {
        do {
            _ = try await commentRepository.saveComment(id: hierarchicalComment.commentModel.comment.id,
                                                    shouldSave: !hierarchicalComment.commentModel.saved)
        } catch {
            appState.contextualError = .init(underlyingError: error)
        }
//        guard !dirty else {
//            return
//        }
//
//        defer { dirty = false }
//        dirty = true
//        dirtySaved.toggle()
//
//        do {
//            let response = try await commentRepository.saveComment(
//                id: hierarchicalComment.id,
//                shouldSave: dirtySaved
//            )
//
//            commentTracker.comments.update(with: response.commentModel)
//        } catch {
//            errorHandler.handle(
//                .init(underlyingError: error)
//            )
//        }

    }
    
    // MARK: helpers
    
    // swiftlint:disable function_body_length
    func genMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // upvote
        let (upvoteText, upvoteImg) = hierarchicalComment.commentModel.votes.myVote == .upvote ?
        ("Undo upvote", "arrow.up.square.fill") :
        ("Upvote", "arrow.up.square")
        ret.append(MenuFunction(
            text: upvoteText,
            imageName: upvoteImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                await upvote()
            }
        })
        
        // downvote
        let (downvoteText, downvoteImg) = hierarchicalComment.commentModel.votes.myVote == .downvote ?
        ("Undo downvote", "arrow.down.square.fill") :
        ("Downvote", "arrow.down.square")
        ret.append(MenuFunction(
            text: downvoteText,
            imageName: downvoteImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                await downvote()
            }
        })
        
        // save
        let (saveText, saveImg) = hierarchicalComment.commentModel.saved ? ("Unsave", "bookmark.slash") : ("Save", "bookmark")
        ret.append(MenuFunction(
            text: saveText,
            imageName: saveImg,
            destructiveActionPrompt: nil,
            enabled: true) {
            Task(priority: .userInitiated) {
                await saveComment()
            }
        })
        
        // reply
        ret.append(MenuFunction(
            text: "Reply",
            imageName: "arrowshape.turn.up.left",
            destructiveActionPrompt: nil,
            enabled: true) {
                replyToComment()
            })
        
        // edit
        if hierarchicalComment.commentModel.creator.id == appState.currentActiveAccount.id {
            ret.append(MenuFunction(
                text: "Edit",
                imageName: "pencil",
                destructiveActionPrompt: nil,
                enabled: true) {
                    editComment()
                })
        }
        
        // delete
        if hierarchicalComment.commentModel.creator.id == appState.currentActiveAccount.id {
            ret.append(MenuFunction(
                text: "Delete",
                imageName: "trash",
                destructiveActionPrompt: "Are you sure you want to delete this comment?  This cannot be undone.",
                enabled: !hierarchicalComment.commentModel.comment.deleted) {
                Task(priority: .userInitiated) {
                    await deleteComment()
                }
            })
        }
        
        // share
        if let url = URL(string: hierarchicalComment.commentModel.comment.apId) {
            ret.append(MenuFunction(
                text: "Share",
                imageName: "square.and.arrow.up",
                destructiveActionPrompt: nil,
                enabled: true) {
                showShareSheet(URLtoShare: url)
            })
        }
        
        // report
        ret.append(MenuFunction(
            text: "Report",
            imageName: AppConstants.reportSymbolName,
            destructiveActionPrompt: nil,
            enabled: true) {
                editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                                   comment: hierarchicalComment.commentModel,
                                                                   operation: CommentOperation.reportComment))
            })
        
        // block
        ret.append(MenuFunction(text: "Block User",
                                imageName: AppConstants.blockUserSymbolName,
                                destructiveActionPrompt: nil,
                                enabled: true) {
            Task(priority: .userInitiated) {
                await blockUser(userId: hierarchicalComment.commentModel.creator.id)
            }
        })
                   
        return ret
    }
    
    func blockUser(userId: Int) async {
        do {
            let blocked = try await blockPerson(
                account: appState.currentActiveAccount,
                personId: userId,
                blocked: true
            )
            
            // TODO: remove from feed--requires generic feed tracker support for removing by filter condition
            if blocked {
                await notifier.add(.success("Blocked user"))
                commentTracker.filter { comment in
                    comment.commentModel.creator.id != userId
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
    // swiftlint:enable function_body_length
}
