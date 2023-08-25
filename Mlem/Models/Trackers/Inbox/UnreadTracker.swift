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
    
    func readReply() {
        replies -= 1
        total -= 1
    }
    
    func unreadReply() {
        replies += 1
        total += 1
    }
    
    func readMention() {
        mentions -= 1
        total -= 1
    }
    
    func unreadMention() {
        mentions += 1
        total += 1
    }
    
    func readMessage() {
        messages -= 1
        total -= 1
    }
    
    func unreadMessage() {
        messages += 1
        total += 1
    }
}
