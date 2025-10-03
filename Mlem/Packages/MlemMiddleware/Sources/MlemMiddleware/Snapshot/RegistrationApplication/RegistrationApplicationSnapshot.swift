//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-05-10.
//

import Foundation

public struct RegistrationApplicationSnapshot: CacheIdentifiable {
    // Won't change.
    public let id: Int
    public let created: Date
    
    // I don't *think* these can change, but I'm assuming they do
    // incase the ability to edit applications is added in future.
    // Update RegistrationApplication if you change these!
    public let questionResponse: String
    public let email: String?
    public let showNsfw: Bool
    public let creator: Person1Snapshot

    // May change. If you add/remove items from this list,
    // remember to also amend the `update` method of RegistrationApplication!
    public let emailVerified: Bool
    public let resolver: Person1Snapshot?
    public let resolution: RegistrationApplication.ResolutionState
    
    public var cacheId: Int { id }
    
    public init(
        id: Int,
        created: Date,
        questionResponse: String,
        email: String?,
        showNsfw: Bool,
        creator: Person1Snapshot,
        emailVerified: Bool,
        resolver: Person1Snapshot?,
        resolution: RegistrationApplication.ResolutionState
    ) {
        self.id = id
        self.created = created
        self.questionResponse = questionResponse
        self.email = email
        self.showNsfw = showNsfw
        self.creator = creator
        self.emailVerified = emailVerified
        self.resolver = resolver
        self.resolution = resolution
    }
}
