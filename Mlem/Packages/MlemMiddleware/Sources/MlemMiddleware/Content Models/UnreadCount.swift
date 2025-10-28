//
//  UnreadCount.swift
//
//
//  Created by Sjmarf on 05/07/2024.
//

import Foundation
import os

@Observable
public final class UnreadCount {
    let log: Logger = .mlemLogger()
    
    public let api: ApiClient
    
    var verifiedCount: [InboxItemType: Int] = .init()
    var unverifiedCount: [InboxItemType: Int] = .init()
    
    public var replies: Int { self[.reply] }
    public var mentions: Int { self[.mention] }
    public var messages: Int { self[.message] }
    public var postReports: Int { self[.postReport] }
    public var commentReports: Int { self[.commentReport] }
    public var messageReports: Int { self[.messageReport] }
    public var registrationApplications: Int { self[.registrationApplication] }
    
    /// This value is incremented whenever the inbox count changes due to an
    /// updated unread count being fetched from the API. It is not incremented when
    /// state-faking is performed. This can be used as a trigger to decide when to
    /// refresh the inbox.
    public private(set) var refreshNumber: UInt = 0
    
    public var personalTotal: Int { replies + mentions + messages }
    public var reportTotal: Int { postReports + commentReports + messageReports }
    public var moderationTotal: Int { reportTotal + registrationApplications }
    public var total: Int { personalTotal + moderationTotal }
    
    init(api: ApiClient) {
        self.api = api
    }
    
    @MainActor
    func update(with newValues: [InboxItemType: Int]) {
        var shouldUpdate = false
        for (type, value) in newValues {
            if verifiedCount[type] != value {
                verifiedCount[type] = value
                shouldUpdate = true
            }
        }
        if shouldUpdate {
            refreshNumber += 1
        }
    }
    
    @MainActor
    func update(with sources: [any DictionaryConvertible]) {
        update(
            with: sources.reduce(into: [InboxItemType: Int]()) {
                $0.merge($1.unreadCountDictionary) { $1 }
            }
        )
    }
    
    func clear() {
        verifiedCount = .init()
        unverifiedCount = .init()
    }
    
    func clear(_ types: Set<InboxItemType>) {
        for type in types {
            verifiedCount[type] = 0
            unverifiedCount[type] = 0
        }
    }
    
    func updateUnverifiedItem(itemType: InboxItemType, isRead: Bool) {
        let diff = isRead ? -1 : 1
        unverifiedCount[itemType, default: 0] += diff
    }
    
    func verifyItem(itemType: InboxItemType, isRead: Bool) {
        let diff = isRead ? -1 : 1
        verifiedCount[itemType, default: 0] += diff
        unverifiedCount[itemType, default: 0] -= diff
    }
    
    public subscript(_ type: InboxItemType) -> Int {
        (verifiedCount[type] ?? 0) + (unverifiedCount[type] ?? 0)
    }
    
    // If `alwaysMakeCalls` is `false`, `UnreadCount` will avoid making calls it doesn't need to (e.g. checking for
    // moderation notifications if the user does not moderate any communities). You might want to set this to
    // `true` if you are using this function to measure the response time of the server.
    public func refresh(alwaysMakeCalls: Bool = false) async throws {
        let values: [InboxItemType: Int] = try await withThrowingTaskGroup(
            of: [InboxItemType: Int].self,
            returning: [InboxItemType: Int].self
        ) { taskGroup in
            taskGroup.addTask {
                try await self.api.repository.getPersonalUnreadCount().unreadCountDictionary
            }
            if !alwaysMakeCalls, self.api.username != nil, self.api.myPerson == nil || self.api.myInstance == nil {
                // The theoretical solution to this is to store the moderated
                // community IDs in `ApiClient.Context` and `await` them here.
                log.warning("ApiClient.myPerson or ApiClient.myInstance is nil at UnreadCount refresh - this may lead to unneeded API calls")
            }
            
            if try await self.api.supports(.viewReports) {
                if alwaysMakeCalls || !(self.api.myPerson?.moderatedCommunities.isEmpty ?? false) || self.api.isAdmin {
                    taskGroup.addTask {
                        do {
                            return try await self.api.repository.getReportCount(communityId: nil).unreadCountDictionary
                        } catch let ApiClientError.response(response, _) where response.notModOrAdmin {
                            return [:]
                        }
                    }
                }
                // Don't use `api.isAdmin` here; it falls back to `false` and we need to fallback to `true`
                if alwaysMakeCalls || api.myInstance?.administrators.contains(where: { $0.id == api.myPerson?.id }) ?? true {
                    taskGroup.addTask {
                        do {
                            return try await [.registrationApplication: self.api.getRegistrationApplicationCount()]
                        } catch let ApiClientError.response(response, _) where response.notAdmin {
                            return [:]
                        }
                    }
                }
            }
            return try await taskGroup.reduce(into: [:]) { $0.merge($1) { $1 } }
        }
        await update(with: values)
    }
}

public enum InboxItemType: Codable {
    case reply, mention, message
    case postReport, commentReport, messageReport, registrationApplication
}

public extension Set<InboxItemType> {
    static var all: Set<InboxItemType> {
        [.reply, .mention, .message, .postReport, .commentReport, .messageReport, .registrationApplication]
    }
    
    static var personal: Set<InboxItemType> {
        [.reply, .mention, .message]
    }
    
    static var reports: Set<InboxItemType> {
        [.postReport, .commentReport, .messageReport]
    }
    
    static var moderatorAndAdmin: Set<InboxItemType> {
        reports.union([.registrationApplication])
    }
}

extension UnreadCount {
    protocol DictionaryConvertible {
        var unreadCountDictionary: [InboxItemType: Int] { get }
    }
}
