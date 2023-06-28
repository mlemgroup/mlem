//
//  Inbox Feed View Logic.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-26.
//

import Foundation

enum MyError: Error {
    case runtimeError(String)
}

extension InboxView {
    func refreshFeed() async {
        do {
            try await mentionsTracker.refresh(account: account)
            try await messagesTracker.refresh(account: account)
            try await repliesTracker.refresh(account: account)
            
            errorOccurred = false
            
            aggregateAllTrackers()
        } catch APIClientError.networking {
            // We're seeing a number of SSL related errors on some instances while loading pages from the feed
            errorOccurred = true
            errorMessage = "Network error occurred, please file a bug report including the instance you are using"
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
    
    // TODO: unify these
    func loadMentions() async {
        do {
            try await mentionsTracker.loadNextPage(account: account, sort: .new)
            aggregateAllTrackers()
            // TODO: make that call above return the new items and do a nice neat merge sort that doesn't re-sort the whole damn array
        } catch let message {
            print(message)
        }
    }
    
    func loadMessages() async {
        do {
            try await messagesTracker.loadNextPage(account: account)
            aggregateAllTrackers()
        } catch let message {
            print(message)
        }
    }
    
    func loadReplies() async {
        do {
            try await repliesTracker.loadNextPage(account: account)
            aggregateAllTrackers()
        } catch let message {
            print(message)
        }
    }
    
    func aggregateAllTrackers() {
        let mentions = mentionsTracker.mentions.map { item in
            InboxItem(published: item.personMention.published, id: item.personMention.id, type: .mention(item))
        }
        
        let messages = messagesTracker.messages.map { item in
            InboxItem(published: item.privateMessage.published, id: item.id, type: .message(item))
        }
        
        let replies = repliesTracker.replies.map { item in
            InboxItem(published: item.commentReply.published, id: item.commentReply.id, type: .reply(item))
        }
        
        allItems = merge(arr1: mentions, arr2: messages, compare: wasPostedAfter)
        allItems = merge(arr1: allItems, arr2: replies, compare: wasPostedAfter)
    }
    
    /**
     returns true if lhs was posted after rhs
     */
    func wasPostedAfter(lhs: InboxItem, rhs: InboxItem) -> Bool {
        return lhs.published > rhs.published
    }
}
