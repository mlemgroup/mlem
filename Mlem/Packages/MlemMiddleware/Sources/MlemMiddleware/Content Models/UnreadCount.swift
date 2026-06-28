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

    struct Count: Hashable {
        var personal: Int = 0
        var moderation: Int = 0

        subscript(_ type: InboxItemType) -> Int {
            get {
                switch type {
                case .personal: personal
                case .moderation: moderation
                }
            }
            set {
                switch type {
                case .personal: personal = newValue
                case .moderation: moderation = newValue
                }
            }
        }

        static func +(lhs: Self, rhs: Self) -> Self {
            .init(personal: lhs.personal + rhs.personal, moderation: lhs.moderation + rhs.moderation)
        }
    }
    
    var verifiedCount: Count = .init()
    var unverifiedCount: Count = .init()
    
    public var personal: Int { verifiedCount.personal + unverifiedCount.personal }
    public var moderation: Int { verifiedCount.moderation + unverifiedCount.moderation }
    
    /// This value is incremented whenever the inbox count changes due to an
    /// updated unread count being fetched from the API. It is not incremented when
    /// state-faking is performed. This can be used as a trigger to decide when to
    /// refresh the inbox.
    public private(set) var refreshNumber: UInt = 0
    
    init(api: ApiClient) {
        self.api = api
    }
    
    @MainActor
    func update(with newCounts: Count) {
        if newCounts != self.verifiedCount {
            self.verifiedCount = newCounts
            refreshNumber += 1
        }
    }
    
    func clear() {
        verifiedCount = .init()
        unverifiedCount = .init()
    }
    
    func clear(_ type: InboxItemType) {
        self.verifiedCount[type] = 0
        self.unverifiedCount[type] = 0
    }

    func updateUnverifiedItem(itemType: InboxItemType, isRead: Bool) {
        let diff = isRead ? -1 : 1
        unverifiedCount[itemType] += diff
    }
    
    func verifyItem(itemType: InboxItemType, isRead: Bool) {
        let diff = isRead ? -1 : 1
        verifiedCount[itemType] += diff
        unverifiedCount[itemType] -= diff
    }
    
    public subscript(_ type: InboxItemType) -> Int {
        verifiedCount[type] + unverifiedCount[type]
    }
    
    public func refresh() async throws {
        let values: Count = try await withThrowingTaskGroup(of: Count.self, returning: Count.self) { taskGroup in
            taskGroup.addTask {
                let total = try await self.api.repository.getPersonalUnreadCount().total
                return .init(personal: total, moderation: 0)
            }
            if  self.api.username != nil, self.api.myPerson == nil || self.api.myInstance == nil {
                // The theoretical solution to this is to store the moderated
                // community IDs in `ApiClient.Context` and `await` them here.
                log.warning("ApiClient.myPerson or ApiClient.myInstance is nil at UnreadCount refresh - this may lead to unneeded API calls")
            }
            
            if try await self.api.supports(.viewReports) {
                if !(self.api.myPerson?.moderatedCommunities.value_?.isEmpty ?? false) || self.api.isAdmin {
                    taskGroup.addTask {
                        do {
                            let total = try await self.api.repository.getReportCount(communityId: nil).total
                            return .init(personal: 0, moderation: total)
                        } catch ApiClientError.notModOrAdmin {
                            return .init()
                        }
                    }
                }
                // Don't use `api.isAdmin` here; it falls back to `false` and we need to fallback to `true`
                if api.myInstance?.administrators.value?.contains(where: { $0.id == api.myPerson?.id }) ?? true {
                    taskGroup.addTask {
                        do {
                            let total = try await self.api.getRegistrationApplicationCount()
                            return .init(personal: 0, moderation: total)
                        } catch ApiClientError.notAdmin {
                            return .init()
                        }
                    }
                }
            }
            return try await taskGroup.reduce(.init(), +)
        }
        await update(with: values)
    }
}

public enum InboxItemType: Codable, CaseIterable {
    case personal, moderation
}

public enum LegacyInboxItemType: Codable {
    case reply, mention, message
    case postReport, commentReport, messageReport, registrationApplication
}

public extension Set<InboxItemType> {
    init(legacyTypes: Set<LegacyInboxItemType>) {
        self = switch legacyTypes {
        case [.reply, .mention, .message]: [.personal]
        case [.postReport, .commentReport, .messageReport, .registrationApplication]: [.moderation]
        default: [.personal, .moderation]
        }
    }

    static var all: Self { Set(InboxItemType.allCases) }
}

