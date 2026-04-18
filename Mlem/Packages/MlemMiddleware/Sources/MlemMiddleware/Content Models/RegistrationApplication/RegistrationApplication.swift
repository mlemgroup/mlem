//
//  RegistrationApplication1.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-12.
//

import Foundation

// This could be two-tiered but doing so is tricky because whether the application has
// been approved or denied is unknown at tier 1, which would make the tier 1 model pretty
// useless. At this time, only tier 2 applications are returned anyways.

@Observable
public final class RegistrationApplication: ContentIdentifiable, FeedLoadable {
    public typealias FilterType = ModMailItemFilterType
    
    public static let modelTypeId: ContentType = .registrationApplication
    public let api: ApiClient
    
    public let id: Int
    public internal(set) var questionResponse: String
    public let creator: Person
    public internal(set) var resolver: Person?
    public internal(set) var email: String?
    public internal(set) var emailVerified: Bool
    public internal(set) var showNsfw: Bool
    public let created: Date
    
    var resolutionManager: StateManager<ResolutionState>
    public var resolution: ResolutionState { resolutionManager.displayedValue }
    
    init(
        api: ApiClient,
        id: Int,
        questionResponse: String,
        creator: Person,
        resolver: Person?,
        email: String?,
        emailVerified: Bool,
        showNsfw: Bool,
        created: Date,
        resolution: ResolutionState
    ) {
        self.api = api
        self.id = id
        self.questionResponse = questionResponse
        self.creator = creator
        self.resolver = resolver
        self.email = email
        self.emailVerified = emailVerified
        self.showNsfw = showNsfw
        self.created = created
        self.resolutionManager = .init(wrappedValue: resolution)
        resolutionManager.onSet = { newValue, type, _ in
            if type == .begin || type == .rollback {
                api.unreadCount?.updateUnverifiedItem(itemType: .registrationApplication, isRead: newValue != .unresolved)
            }
        }
        resolutionManager.onVerify = { newValue, _ in
            api.unreadCount?.verifyItem(itemType: .registrationApplication, isRead: newValue != .unresolved)
        }
    }
    
    var modMailId: Int {
        var hasher: Hasher = .init()
        hasher.combine("application")
        hasher.combine(id)
        return hasher.finalize()
    }
    
    public func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new: .new(created)
        }
    }
    
    @discardableResult
    public func approve() -> Task<StateUpdateResult, Never> {
        resolutionManager.performRequest(expectedResult: .approved) { semaphore in
            try await self.api.approveRegistrationApplication(id: self.id, semaphore: semaphore)
        }
    }
    
    @discardableResult
    public func deny(reason: String?) -> Task<StateUpdateResult, Never> {
        resolutionManager.performRequest(expectedResult: .denied(reason: reason)) { semaphore in
            try await self.api.denyRegistrationApplication(id: self.id, reason: reason, semaphore: semaphore)
        }
    }
}

public extension RegistrationApplication {
    enum ResolutionState: Equatable {
        case unresolved, approved, denied(reason: String?)
        
        public var reason: String? {
            switch self {
            case .unresolved: nil
            case .approved: nil
            case let .denied(reason): reason
            }
        }
        
        public var isDenied: Bool {
            switch self {
            case .denied: true
            default: false
            }
        }
    }
}
