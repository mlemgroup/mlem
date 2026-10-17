//
//  Report.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-10-12.
//

import Observation
import Foundation

import os

@Observable
public class Report: UnifiedModelProviding, FeedLoadable {
    public typealias Properties = ReportProperties
    
    public var api: ApiClient
    private let properties: ReportProperties
    @ObservationIgnored lazy var updateQueue: UnifiedUpdateQueue<Report> = .init(parent: self, properties: properties)
    
    // MARK: API Properties
    // Properties that are provided by teh API
    
    public let id: Int
    public let created: Date
    public let creator: Person
    public let target: ReportTarget
    public var resolver: Person?
    public var updated: Date?
    public var resolved: Bool
    public var reason: String
    
    // MARK: Initializers and Updates
    
    public init(api: ApiClient, properties: ReportProperties) {
        self.api = api
        self.properties = properties
        
        self.id = properties.id
        self.created = properties.created
        self.creator = properties.creator
        self.target = properties.target
        self.resolver = properties.resolver
        self.updated = properties.updated
        self.resolved = properties.resolved
        self.reason = properties.reason
    }
    
    @MainActor
    public func update(with properties: ReportProperties) {
        setIfChanged(\.resolver, properties.resolver)
        setIfChanged(\.updated, properties.updated)
        setIfChanged(\.resolved, properties.resolved)
        setIfChanged(\.reason, properties.reason)
    }
    
    public func softUpdate(with properties: ReportProperties) {
        // noop - no higher-tier properties to update
    }
    
    public func fetchUpgraded() async throws -> ReportProperties {
        assertionFailure("Cannot upgrade Report")
        return self.properties
    }
    
    public func resolve(with api: ApiClient) async throws -> Self {
        assertionFailure("Cannot resolve report")
        throw ApiClientError.invalidInput
    }
}

// MARK: - Computed

public extension Report {
    var modMailId: Int {
        var hasher: Hasher = .init()
        hasher.combine("report")
        hasher.combine(target.type)
        hasher.combine(id)
        return hasher.finalize()
    }
}

// MARK: - Interactions

public extension Report {
    func updateResolved(_ newValue: Bool) {
        self.resolved = newValue
        api.unreadCount?.updateUnverifiedItem(itemType: .moderation, isRead: newValue)
        
        Task {
            await updateQueue.addItem {
                guard let myPersonId = try await self.api.myPersonId else { throw ApiClientError.notLoggedIn }
                
                var ret: ReportProperties
                switch self.target.type {
                case .post:
                    let snapshot = try await self.api.repository.resolvePostReport(id: self.id, resolved: self.resolved)
                    ret = await .init(api: self.api, snapshot: snapshot, myPersonId: myPersonId)
                case .comment:
                    let snapshot = try await self.api.repository.resolveCommentReport(id: self.id, resolved: self.resolved)
                    ret = await .init(api: self.api, snapshot: snapshot, myPersonId: myPersonId)
                case .message:
                    let snapshot = try await self.api.repository.resolveMessageReport(id: self.id, resolved: self.resolved)
                    ret = await .init(api: self.api, snapshot: snapshot, myPersonId: myPersonId)
                }
                
                self.api.unreadCount?.verifyItem(itemType: .moderation, isRead: ret.resolved)
                return ret
            }
        }
    }
    
    func toggleResolved() {
        updateResolved(!resolved)
    }
}
