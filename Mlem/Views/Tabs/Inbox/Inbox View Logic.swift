//
//  Inbox Feed View Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

extension InboxView {
    func refreshFeed() async {
        do {
            isLoading = true
            
            // only refresh the trackers we need
            if curTab == .all || curTab == .mentions {
                print("refreshing mentions")
                try await mentionsTracker.refresh(account: account)
            }
            if curTab == .all || curTab == .messages {
                print("refreshing messages")
                try await messagesTracker.refresh(account: account)
            }
            if curTab == .all || curTab == .replies {
                print("refreshing replies")
                try await repliesTracker.refresh(account: account)
            }
            
            errorOccurred = false
            
            if curTab == .all {
                aggregateAllTrackers()
            }
        } catch APIClientError.networking {
            errorOccurred = true
            errorMessage = "Network error occurred, check your internet and retry"
        } catch APIClientError.response(let message, _) {
            print(message)
            errorOccurred = true
            errorMessage = "API error occurred, try refreshing"
        } catch APIClientError.cancelled {
            print("Failed while loading feed (request cancelled)")
            errorOccurred = true
            errorMessage = "Request was cancelled, try refreshing"
        } catch let message {
            print(message)
            errorOccurred = true
            errorMessage = "A decoding error occurred, try refreshing."
        }

    }
    
    func loadTrackerPage(tracker: InboxTracker) async {
        do {
            try await tracker.loadNextPage(account: account)
            aggregateAllTrackers()
            // TODO: make that call above return the new items and do a nice neat merge sort that doesn't re-merge the whole damn array
        } catch let message {
            print(message)
        }
    }
    
    func aggregateAllTrackers() {
        let mentions = mentionsTracker.items.map { item in
            InboxItem(published: item.personMention.published, id: item.id, type: .mention(item))
        }
        
        let messages = messagesTracker.items.map { item in
            InboxItem(published: item.privateMessage.published, id: item.id, type: .message(item))
        }
        
        let replies = repliesTracker.items.map { item in
            InboxItem(published: item.commentReply.published, id: item.id, type: .reply(item))
        }
        
        allItems = merge(arr1: mentions, arr2: messages, compare: wasPostedAfter)
        allItems = merge(arr1: allItems, arr2: replies, compare: wasPostedAfter)
        isLoading = false
    }
    
    /**
     returns true if lhs was posted after rhs
     */
    func wasPostedAfter(lhs: InboxItem, rhs: InboxItem) -> Bool {
        return lhs.published > rhs.published
    }
    
    // INTERACTION
    func voteOnComment(comment: APIComment) {
        print("voting on \(comment.content)")
    }
    
    func genCommentReplyMenuGroup(commentReply: APICommentReplyView) -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        // upvote
        let (upvoteText, upvoteImg) = commentReply.myVote == .upvote ?
        ("Undo upvote", "arrow.up.square.fill") :
        ("Upvote", "arrow.up.square")
        ret.append(MenuFunction(text: upvoteText, imageName: upvoteImg) {
            Task(priority: .userInitiated) {
                await voteOnCommentReply(commentReply: commentReply, inputOp: .upvote)
            }
        })
        
        // downvote
        let (downvoteText, downvoteImg) = commentReply.myVote == .downvote ?
        ("Undo downvote", "arrow.down.square.fill") :
        ("Downvote", "arrow.down.square")
        ret.append(MenuFunction(text: downvoteText, imageName: downvoteImg) {
            Task(priority: .userInitiated) {
                await voteOnCommentReply(commentReply: commentReply, inputOp: .downvote)
            }
        })
        
        // mark read
        let (readText, readImg) = commentReply.commentReply.read ?
        ("Mark unread", "envelope.open.fill") :
        ("Mark read", "envelope")
        ret.append(MenuFunction(text: readText, imageName: readImg) {
            Task(priority: .userInitiated) {
                await markCommentReplyRead(commentReply: commentReply, read: !commentReply.commentReply.read)
            }
        })
        
        return ret
    }
    
    func voteOnCommentReply(commentReply: APICommentReplyView, inputOp: ScoringOperation) async {
        do {
            let operation = commentReply.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            try await _ = rateCommentReply(commentReply: commentReply,
                                           operation: operation,
                                           account: account,
                                           commentReplyTracker: repliesTracker,
                                           appState: appState)
        } catch {
            print("failed to vote!")
        }
    }
    
    func markCommentReplyRead(commentReply: APICommentReplyView, read: Bool) async {
        do {
            try await sendMarkCommentReplyAsReadRequest(commentReply: commentReply,
                                                        read: read, account: account,
                                                        commentReplyTracker: repliesTracker,
                                                        appState: appState)
        } catch {
            print("failed to mark read!")
        }
    }
}
