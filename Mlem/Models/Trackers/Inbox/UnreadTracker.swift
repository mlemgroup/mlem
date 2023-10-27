//
//  UnreadTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-26.
//

import Foundation

class UnreadTracker: ObservableObject {
    @Published private(set) var replies: Int
    @Published private(set) var mentions: Int
    @Published private(set) var messages: Int
    @Published private(set) var total: Int
    
    init() {
        self.replies = 0
        self.mentions = 0
        self.messages = 0
        self.total = 0
    }
    
    @MainActor
    func update(with counts: APIPersonUnreadCounts) {
        replies = counts.replies
        mentions = counts.mentions
        messages = counts.privateMessages
        total = counts.replies + counts.mentions + counts.privateMessages
    }
    
    @MainActor
    func reset() {
        replies = 0
        mentions = 0
        messages = 0
        total = 0
    }
    
    @MainActor
    func readReply() {
        replies -= 1
        total -= 1
    }
    
    @MainActor
    func unreadReply() {
        replies += 1
        total += 1
    }
    
    @MainActor
    func readMention() {
        mentions -= 1
        total -= 1
    }
    
    @MainActor
    func unreadMention() {
        mentions += 1
        total += 1
    }
    
    @MainActor
    func readMessage() {
        messages -= 1
        total -= 1
    }
    
    @MainActor
    func unreadMessage() {
        messages += 1
        total += 1
    }
    
    // convenience methods to flip a read state (if originalState is true (read), will unread a message; if false, will read a message)
    
    @MainActor
    func toggleReplyRead(originalState: Bool) {
        if originalState {
            unreadReply()
        } else {
            readReply()
        }
    }
    
    @MainActor
    func toggleMentionRead(originalState: Bool) {
        if originalState {
            unreadMention()
        } else {
            readMention()
        }
    }
    
    @MainActor
    func toggleMessageRead(originalState: Bool) {
        if originalState {
            unreadMessage()
        } else {
            readMessage()
        }
    }
}
