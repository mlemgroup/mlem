//
//  Report.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2024-12-15.
//

import Foundation
import Observation

@Observable
public class Report: CacheIdentifiable, ContentModel, FeedLoadable {
    public typealias FilterType = ModMailItemFilterType
    
    public static let tierNumber: Int = 1
    public var api: ApiClient
    
    // Keep this internal - a post report and a comment report can have the same ID, so it's not a true identifier.
    var id: Int
    
    public let created: Date
    public internal(set) var updated: Date?
    public let creator: Person1
    public let target: ReportTarget
    public internal(set) var resolver: Person1?
    public internal(set) var reason: String
    
    var resolvedManager: StateManager<Bool>
    public var resolved: Bool { resolvedManager.displayedValue }
    
    init(
        api: ApiClient,
        id: Int,
        creator: Person1,
        resolver: Person1?,
        target: ReportTarget,
        resolved: Bool,
        reason: String,
        created: Date,
        updated: Date?
    ) {
        self.api = api
        self.id = id
        self.creator = creator
        self.resolver = resolver
        self.target = target
        self.reason = reason
        self.created = created
        self.updated = updated
        
        self.resolvedManager = .init(wrappedValue: resolved)
        resolvedManager.onSet = { newValue, type, _ in
            if type == .begin || type == .rollback {
                api.unreadCount?.updateUnverifiedItem(itemType: target.type.inboxItemType, isRead: newValue)
            }
        }
        resolvedManager.onVerify = { newValue, _ in
            api.unreadCount?.verifyItem(itemType: target.type.inboxItemType, isRead: newValue)
        }
    }
    
    public var modMailId: Int {
        var hasher: Hasher = .init()
        hasher.combine("report")
        hasher.combine(target.case)
        hasher.combine(id)
        return hasher.finalize()
    }
    
    @discardableResult
    public func updateResolved(_ newValue: Bool) -> Task<StateUpdateResult, Never> {
        resolvedManager.performRequest(expectedResult: newValue) { semaphore in
            switch self.target.type {
            case .post:
                try await self.api.resolvePostReport(id: self.id, resolved: newValue, semaphore: semaphore)
            case .comment:
                try await self.api.resolveCommentReport(id: self.id, resolved: newValue, semaphore: semaphore)
            case .message:
                try await self.api.resolveMessageReport(id: self.id, resolved: newValue, semaphore: semaphore)
            }
        }
    }
    
    @discardableResult
    public func toggleResolved() -> Task<StateUpdateResult, Never> {
        updateResolved(!resolved)
    }
    
    public func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new: .new(created)
        }
    }
    
    public static func == (lhs: Report, rhs: Report) -> Bool {
        lhs.target.case == rhs.target.case && lhs.id == rhs.id
    }
}
