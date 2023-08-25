//
//  Messages Feed View Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-02.
//

import Foundation

extension InboxView {
    // MARK: Replies -
    
    func upvoteCommentReplySwipeAction(commentReply: APICommentReplyView) -> SwipeAction {
        let (emptySymbolName, fullSymbolName) = commentReply.myVote == .upvote ?
            (AppConstants.emptyResetVoteSymbolName, AppConstants.fullResetVoteSymbolName) :
            (AppConstants.emptyUpvoteSymbolName, AppConstants.fullUpvoteSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .upvoteColor
        ) {
            voteOnCommentReply(commentReply: commentReply, inputOp: .upvote)
        }
    }
    
    func downvoteCommentReplySwipeAction(commentReply: APICommentReplyView) -> SwipeAction {
        let (emptySymbolName, fullSymbolName) = commentReply.myVote == .downvote ?
            (AppConstants.emptyResetVoteSymbolName, AppConstants.fullResetVoteSymbolName) :
            (AppConstants.emptyDownvoteSymbolName, AppConstants.fullDownvoteSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .downvoteColor
        ) {
            voteOnCommentReply(commentReply: commentReply, inputOp: .downvote)
        }
    }
    
    func toggleCommentReplyReadSwipeAction(commentReply: APICommentReplyView) -> SwipeAction {
        let (emptySymbolName, fullSymbolName) = commentReply.commentReply.read ?
            (AppConstants.emptyMarkUnreadSymbolName, AppConstants.fullMarkUnreadSymbolName) :
            (AppConstants.emptyMarkReadSymbolName, AppConstants.fullMarkReadSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .purple
        ) {
            toggleCommentReplyRead(commentReplyView: commentReply)
        }
    }
    
    func replyToCommentReplySwipeAction(commentReply: APICommentReplyView) -> SwipeAction? {
        SwipeAction(
            symbol: .init(emptyName: AppConstants.emptyReplySymbolName, fillName: AppConstants.fullReplySymbolName),
            color: .accentColor
        ) {
            replyToCommentReply(commentReply: commentReply)
        }
    }
    
    func genCommentReplyMenuGroup(commentReply: APICommentReplyView) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // upvote
        let (upvoteText, upvoteImg) = commentReply.myVote == .upvote ?
            ("Undo upvote", "arrow.up.square.fill") :
            ("Upvote", "arrow.up.square")
        ret.append(MenuFunction(text: upvoteText, imageName: upvoteImg, destructiveActionPrompt: nil, enabled: true) {
            voteOnCommentReply(commentReply: commentReply, inputOp: .upvote)
        })
        
        // downvote
        let (downvoteText, downvoteImg) = commentReply.myVote == .downvote ?
            ("Undo downvote", "arrow.down.square.fill") :
            ("Downvote", "arrow.down.square")
        ret.append(MenuFunction(text: downvoteText, imageName: downvoteImg, destructiveActionPrompt: nil, enabled: true) {
            voteOnCommentReply(commentReply: commentReply, inputOp: .downvote)
        })
        
        // mark read
        let (markReadText, markReadImg) = commentReply.commentReply.read ?
            ("Mark unread", "envelope.fill") :
            ("Mark read", "envelope.open")
        ret.append(MenuFunction(text: markReadText, imageName: markReadImg, destructiveActionPrompt: nil, enabled: true) {
            toggleCommentReplyRead(commentReplyView: commentReply)
        })
        
        // reply
        ret.append(MenuFunction(text: "Reply", imageName: "arrowshape.turn.up.left", destructiveActionPrompt: nil, enabled: true) {
            replyToCommentReply(commentReply: commentReply)
        })
        
        // report
        ret.append(MenuFunction(
            text: "Report Comment",
            imageName: AppConstants.reportSymbolName,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            reportCommentReply(commentReply: commentReply)
        })
        
        // block
        ret.append(MenuFunction(
            text: "Block User",
            imageName: AppConstants.blockUserSymbolName,
            destructiveActionPrompt: AppConstants.blockUserPrompt,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await blockUser(userId: commentReply.creator.id)
            }
        })
        
        return ret
    }
    
    // MARK: Mentions -
    
    func upvoteMentionSwipeAction(mentionView: APIPersonMentionView) -> SwipeAction {
        let (emptySymbolName, fullSymbolName) = mentionView.myVote == .upvote ?
            (AppConstants.emptyResetVoteSymbolName, AppConstants.fullResetVoteSymbolName) :
            (AppConstants.emptyUpvoteSymbolName, AppConstants.fullUpvoteSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .upvoteColor
        ) {
            voteOnMention(mention: mentionView, inputOp: .upvote)
        }
    }
    
    func downvoteMentionSwipeAction(mentionView: APIPersonMentionView) -> SwipeAction {
        let (emptySymbolName, fullSymbolName) = mentionView.myVote == .downvote ?
            (AppConstants.emptyResetVoteSymbolName, AppConstants.fullResetVoteSymbolName) :
            (AppConstants.emptyDownvoteSymbolName, AppConstants.fullDownvoteSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .downvoteColor
        ) {
            voteOnMention(mention: mentionView, inputOp: .downvote)
        }
    }
    
    func toggleMentionReadSwipeAction(mentionView: APIPersonMentionView) -> SwipeAction {
        let (emptySymbolName, fullSymbolName) = mentionView.personMention.read ?
            (AppConstants.emptyMarkUnreadSymbolName, AppConstants.fullMarkUnreadSymbolName) :
            (AppConstants.emptyMarkReadSymbolName, AppConstants.fullMarkReadSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .purple
        ) {
            toggleMentionRead(mention: mentionView)
        }
    }
    
    func replyToMentionSwipeAction(mentionView: APIPersonMentionView) -> SwipeAction? {
        SwipeAction(
            symbol: .init(emptyName: AppConstants.emptyReplySymbolName, fillName: AppConstants.fullReplySymbolName),
            color: .accentColor
        ) {
            replyToMention(mention: mentionView)
        }
    }
    
    func genMentionMenuGroup(mention: APIPersonMentionView) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // upvote
        let (upvoteText, upvoteImg) = mention.myVote == .upvote ?
            ("Undo upvote", "arrow.up.square.fill") :
            ("Upvote", "arrow.up.square")
        ret.append(MenuFunction(text: upvoteText, imageName: upvoteImg, destructiveActionPrompt: nil, enabled: true) {
            voteOnMention(mention: mention, inputOp: .upvote)
        })
        
        // downvote
        let (downvoteText, downvoteImg) = mention.myVote == .downvote ?
            ("Undo downvote", "arrow.down.square.fill") :
            ("Downvote", "arrow.down.square")
        ret.append(MenuFunction(text: downvoteText, imageName: downvoteImg, destructiveActionPrompt: nil, enabled: true) {
            voteOnMention(mention: mention, inputOp: .downvote)
        })
        
        // mark read
        let (markReadText, markReadImg) = mention.personMention.read ?
            ("Mark unread", "envelope.fill") :
            ("Mark read", "envelope.open")
        ret.append(MenuFunction(text: markReadText, imageName: markReadImg, destructiveActionPrompt: nil, enabled: true) {
            toggleMentionRead(mention: mention)
        })
        
        // reply
        ret.append(MenuFunction(text: "Reply", imageName: "arrowshape.turn.up.left", destructiveActionPrompt: nil, enabled: true) {
            replyToMention(mention: mention)
        })
        
        // report
        ret.append(MenuFunction(
            text: "Report Comment",
            imageName: AppConstants.reportSymbolName,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            reportMention(mention: mention)
        })

        // block
        ret.append(MenuFunction(
            text: "Block User",
            imageName: AppConstants.blockUserSymbolName,
            destructiveActionPrompt: AppConstants.blockUserPrompt,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await blockUser(userId: mention.creator.id)
            }
        })
        
        return ret
    }
    
    // MARK: Messages -
    
    func toggleMessageReadSwipeAction(message: APIPrivateMessageView) -> SwipeAction {
        let (emptySymbolName, fullSymbolName) = message.privateMessage.read ?
            (AppConstants.emptyMarkUnreadSymbolName, AppConstants.fullMarkUnreadSymbolName) :
            (AppConstants.emptyMarkReadSymbolName, AppConstants.fullMarkReadSymbolName)
        return SwipeAction(
            symbol: .init(emptyName: emptySymbolName, fillName: fullSymbolName),
            color: .purple
        ) {
            toggleMessageRead(message: message)
        }
    }
    
    func replyToMessageSwipeAction(message: APIPrivateMessageView) -> SwipeAction {
        SwipeAction(
            symbol: .init(emptyName: AppConstants.emptyReplySymbolName, fillName: AppConstants.fullReplySymbolName),
            color: .accentColor
        ) {
            replyToMessage(message: message)
        }
    }
    
    func genMessageMenuGroup(message: APIPrivateMessageView) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // mark read
        let (markReadText, markReadImg) = message.privateMessage.read ?
            ("Mark unread", "envelope.fill") :
            ("Mark read", "envelope.open")
        ret.append(MenuFunction(
            text: markReadText,
            imageName: markReadImg,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            toggleMessageRead(message: message)
        })
        
        // reply
        ret.append(MenuFunction(
            text: "Reply",
            imageName: "arrowshape.turn.up.left",
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            replyToMessage(message: message)
        })
        
        // report
        ret.append(MenuFunction(
            text: "Report Message",
            imageName: AppConstants.reportSymbolName,
            destructiveActionPrompt: nil,
            enabled: true
        ) {
            reportMessage(message: message)
        })
        
        // block
        ret.append(MenuFunction(
            text: "Block User",
            imageName: AppConstants.blockUserSymbolName,
            destructiveActionPrompt: AppConstants.blockUserPrompt,
            enabled: true
        ) {
            Task(priority: .userInitiated) {
                await blockUser(userId: message.creator.id)
            }
        })
        
        return ret
    }
    
    func blockUser(userId: Int) async {
        do {
            let response = try await apiClient.blockPerson(id: userId, shouldBlock: true)
            
            if response.blocked {
                hapticManager.play(haptic: .violentSuccess, priority: .high)
                await notifier.add(.success("Blocked user"))
                filterUser(userId: userId)
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
