//
//  UnreadTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-26.
//

import Dependencies
import Foundation

class UnreadTracker: ObservableObject {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.personRepository) var personRepository
    @Dependency(\.errorHandler) var errorHandler
    
    @Published private(set) var replies: Int
    @Published private(set) var mentions: Int
    @Published private(set) var messages: Int
    @Published private(set) var commentReports: Int
    @Published private(set) var postReports: Int
    @Published private(set) var messageReports: Int
    @Published private(set) var registrationApplications: Int
    
    var total: Int { replies + mentions + messages + commentReports + postReports + messageReports }
    var personal: Int { replies + mentions + messages }
    var mod: Int { commentReports + postReports + messageReports + registrationApplications }
    
    init() {
        self.replies = 0
        self.mentions = 0
        self.messages = 0
        self.commentReports = 0
        self.postReports = 0
        self.messageReports = 0
        self.registrationApplications = 0
    }
    
    @MainActor
    func reset() {
        replies = 0
        mentions = 0
        messages = 0
        commentReports = 0
        postReports = 0
        messageReports = 0
        registrationApplications = 0
    }
    
    @MainActor
    func readReply() { replies -= 1 }
    
    @MainActor
    func unreadReply() { replies += 1 }
    
    @MainActor
    func readMention() { mentions -= 1 }
    
    @MainActor
    func unreadMention() { mentions += 1 }
    
    @MainActor
    func readMessage() { messages -= 1 }
    
    @MainActor
    func unreadMessage() { messages += 1 }
    
    @MainActor
    func readCommentReport() { commentReports -= 1 }
    
    @MainActor
    func unreadCommentReport() { commentReports += 1 }
    
    @MainActor
    func readPostReport() { postReports -= 1 }
    
    @MainActor
    func unreadPostReport() { postReports += 1 }
    
    @MainActor
    func readMessageReport() { messageReports -= 1 }
    
    @MainActor
    func unreadMessageReport() { messageReports += 1 }
    
    @MainActor
    func readRegistrationApplication() { registrationApplications -= 1 }
    
    @MainActor
    func unreadRegistrationApplication() { registrationApplications += 1 }
    
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
    
    // updates from server
    func update() async {
        do {
            let unreadPersonalCounts = try await personRepository.getUnreadCounts()
            let unreadReportCounts = try await apiClient.getUnreadReports(for: nil)
            
            print(unreadReportCounts)
            
            DispatchQueue.main.async {
                self.replies = unreadPersonalCounts.replies
                self.mentions = unreadPersonalCounts.mentions
                self.messages = unreadPersonalCounts.privateMessages
            }
        } catch {
            errorHandler.handle(error)
        }
    }
}
