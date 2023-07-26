//
//  Inbox Feed View Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

extension InboxView {
    
    // MARK: Tracker Updates
    
    func refreshFeed() async {
        do {
            isLoading = true
            
            // load feeds in parallel
            async let repliesRefresh: () = refreshRepliesTracker()
            async let mentionsRefresh: () = refreshMentionsTracker()
            async let messagesRefresh: () = refreshMessagesTracker()
            
            _ = try await [ repliesRefresh, mentionsRefresh, messagesRefresh ]
            
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
        } catch APIClientError.invalidSession {
            appState.contextualError = .init(underlyingError: APIClientError.invalidSession)
        } catch let message {
            print(message)
            errorOccurred = true
            errorMessage = "A decoding error occurred, try refreshing."
        }
    }
    
    func refreshRepliesTracker() async throws {
        if curTab == .all || curTab == .replies {
            try await repliesTracker.refresh(account: appState.currentActiveAccount)
        }
    }
    
    func refreshMentionsTracker() async throws {
        if curTab == .all || curTab == .mentions {
            try await mentionsTracker.refresh(account: appState.currentActiveAccount)
        }
    }
    
    func refreshMessagesTracker() async throws {
        if curTab == .all || curTab == .messages {
            try await messagesTracker.refresh(account: appState.currentActiveAccount)
        }
    }
    
    func filterUser(userId: Int) {
        repliesTracker.filter { reply in
            reply.creator.id != userId
        }
        mentionsTracker.filter { mention in
            mention.creator.id != userId
        }
        messagesTracker.filter { message in
            message.creator.id != userId
        }
        
        aggregateAllTrackers()
    }
    
    func loadTrackerPage(tracker: InboxTracker) async {
        do {
            try await tracker.loadNextPage(account: appState.currentActiveAccount)
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
    
    // MARK: - Replies
    
    func voteOnCommentReply(commentReply: APICommentReplyView, inputOp: ScoringOperation) {
        Task(priority: .userInitiated) {
            let operation = commentReply.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            do {
                let updatedReply = try await commentRepository.voteOnCommentReply(commentReply, vote: operation)
                repliesTracker.update(with: updatedReply)
                if curTab == .all {
                    // TODO: more granular/less expensive merge options
                    aggregateAllTrackers()
                }
            } catch {
                errorHandler.handle(
                    .init(underlyingError: error)
                )
            }
        }
    }
    
    func toggleCommentReplyRead(commentReplyView: APICommentReplyView) {
        Task(priority: .userInitiated) {
            do {
                try await sendMarkCommentReplyAsReadRequest(commentReply: commentReplyView,
                                                            read: !commentReplyView.commentReply.read,
                                                            account: appState.currentActiveAccount,
                                                            commentReplyTracker: repliesTracker,
                                                            appState: appState)
                
                if commentReplyView.commentReply.read {
                    unreadTracker.unreadReply()
                } else {
                    unreadTracker.readReply()
                }
                
                if curTab == .all { aggregateAllTrackers() }
            } catch {
                print("failed to mark read!")
            }
        }
    }
    
    func replyToCommentReply(commentReply: APICommentReplyView) {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           commentReply: commentReply,
                                                           operation: InboxItemOperation.replyToInboxItem))
    }
    
    func reportCommentReply(commentReply: APICommentReplyView) {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           commentReply: commentReply,
                                                           operation: InboxItemOperation.reportInboxItem))
    }
    
    // MARK: Mentions
    
    func voteOnMention(mention: APIPersonMentionView, inputOp: ScoringOperation) {
        Task(priority: .userInitiated) {
            let operation = mention.myVote == inputOp ? ScoringOperation.resetVote : inputOp
            do {
                let updatedMention = try await commentRepository.voteOnPersonMention(mention, vote: operation)
                mentionsTracker.update(with: updatedMention)
                if curTab == .all {
                    aggregateAllTrackers()
                }
            } catch {
                errorHandler.handle(
                    .init(underlyingError: error)
                )
            }
        }
    }
    
    func toggleMentionRead(mention: APIPersonMentionView) {
        Task(priority: .userInitiated) {
            do {
                try await sendMarkPersonMentionAsReadRequest(personMention: mention,
                                                             read: !mention.personMention.read,
                                                             account: appState.currentActiveAccount,
                                                             mentionTracker: mentionsTracker,
                                                             appState: appState)
                
                if mention.personMention.read {
                    unreadTracker.unreadMention()
                } else {
                    unreadTracker.readMention()
                }
                
                if curTab == .all { aggregateAllTrackers() }
            } catch {
                print("failed to mark mention as read!")
            }
        }
    }
    
    func reportMention(mention: APIPersonMentionView) {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           mention: mention,
                                                           operation: InboxItemOperation.reportInboxItem))
    }
    
    func replyToMention(mention: APIPersonMentionView) {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           mention: mention,
                                                           operation: InboxItemOperation.replyToInboxItem))
    }
    
    // MARK: Messages
    
    func toggleMessageRead(message: APIPrivateMessageView) {
        Task(priority: .userInitiated) {
            do {
                try await sendMarkPrivateMessageAsReadRequest(messageView: message,
                                                              read: !message.privateMessage.read,
                                                              account: appState.currentActiveAccount,
                                                              messagesTracker: messagesTracker,
                                                              appState: appState)
                
                if message.privateMessage.read {
                    unreadTracker.unreadMessage()
                } else {
                    unreadTracker.readMessage()
                }
                
                if curTab == .all { aggregateAllTrackers() }
            } catch {
                print("failed to mark message as read!")
            }
        }
    }
    
    func replyToMessage(message: APIPrivateMessageView) {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           message: message,
                                                           operation: InboxItemOperation.replyToInboxItem))
    }
    
    func reportMessage(message: APIPrivateMessageView) {
        editorTracker.openEditor(with: ConcreteEditorModel(appState: appState,
                                                           message: message,
                                                           operation: InboxItemOperation.reportInboxItem))
    }
    
    // MARK: - Helpers
    
    /**
     returns true if lhs was posted after rhs
     */
    func wasPostedAfter(lhs: InboxItem, rhs: InboxItem) -> Bool {
        return lhs.published > rhs.published
    }
    
    func genMenuFunctions() -> [MenuFunction] {
        var ret: [MenuFunction] = .init()
        
        ret.append(MenuFunction(text: "Show Unread",
                                imageName: "line.3.horizontal.decrease.circle",
                                destructiveActionPrompt: nil,
                                enabled: true) {
            print("filtering to only unread")
        })
        
        return ret
    }
}
