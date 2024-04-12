//
//  UnreadTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-26.
//

import Dependencies
import Foundation

struct UnreadCount {
    private(set) var count: Int
    
    init(count: Int) {
        self.count = count
    }
    
    init() {
        self.count = 0
    }
    
    // @MainActor
    mutating func reset() { count = 0 }
    
    // @MainActor
    mutating func read() { count -= 1 }
    
    // @MainActor
    mutating func unread() { count += 1 }
    
    // @MainActor
    mutating func toggleRead(originalState: Bool) {
        if originalState {
            unread()
        } else {
            read()
        }
    }
}

class UnreadTracker: ObservableObject {
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.personRepository) var personRepository
    @Dependency(\.errorHandler) var errorHandler
    @Dependency(\.siteInformation) var siteInformation
    
    @Published var replies: UnreadCount
    @Published var mentions: UnreadCount
    @Published var messages: UnreadCount
    @Published var commentReports: UnreadCount
    @Published var postReports: UnreadCount
    @Published var messageReports: UnreadCount
    @Published var registrationApplications: UnreadCount
    
    var total: Int {
        replies.count +
            mentions.count +
            messages.count +
            commentReports.count +
            postReports.count +
            messageReports.count +
            registrationApplications.count
    }

    var personal: Int { replies.count + mentions.count + messages.count }
    var mod: Int { commentReports.count + postReports.count + messageReports.count + registrationApplications.count }
    
    init() {
        self.replies = .init()
        self.mentions = .init()
        self.messages = .init()
        self.commentReports = .init()
        self.postReports = .init()
        self.messageReports = .init()
        self.registrationApplications = .init()
    }
    
    @MainActor
    func reset() {
        replies.reset()
        mentions.reset()
        messages.reset()
        commentReports.reset()
        postReports.reset()
        messageReports.reset()
        registrationApplications.reset()
    }
    
    func update() async {
        async let asyncPersonalCounts = await fetchUnreadPersonalCounts()
        async let asyncReportCounts = await fetchUnreadReportCounts()
        async let asyncApplicationCount = await fetchUnreadRegistrationApplicationCounts()
        
        let (personalCounts, reportCounts, applicationCount) = await (asyncPersonalCounts, asyncReportCounts, asyncApplicationCount)
        
        DispatchQueue.main.async {
            self.replies = .init(count: personalCounts.replies)
            self.mentions = .init(count: personalCounts.mentions)
            self.messages = .init(count: personalCounts.privateMessages)
            self.commentReports = .init(count: reportCounts.commentReports)
            self.postReports = .init(count: reportCounts.postReports)
            self.messageReports = .init(count: reportCounts.privateMessageReports ?? 0)
            self.registrationApplications = .init(count: applicationCount.registrationApplications)
        }
    }
    
    private func fetchUnreadPersonalCounts() async -> APIPersonUnreadCounts {
        do {
            return try await personRepository.getUnreadCounts()
        } catch {
            errorHandler.handle(error)
        }
        return .init(replies: 0, mentions: 0, privateMessages: 0)
    }
    
    private func fetchUnreadReportCounts() async -> APIGetReportCountResponse {
        do {
            if siteInformation.isAdmin || !siteInformation.moderatedCommunities.isEmpty {
                return try await apiClient.getUnreadReports(for: nil)
            }
        } catch {
            errorHandler.handle(error)
        }
        return .init(communityId: nil, commentReports: 0, postReports: 0, privateMessageReports: 0)
    }
    
    private func fetchUnreadRegistrationApplicationCounts() async -> APIGetUnreadRegistrationApplicationCountResponse {
        do {
            if siteInformation.isAdmin {
                return try await apiClient.getUnreadRegistrationApplications()
            }
        } catch {
            errorHandler.handle(error)
        }
        return .init(registrationApplications: 0)
    }
}
