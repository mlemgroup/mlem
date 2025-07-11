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
    
    public init(from application: LemmyRegistrationApplicationView) throws(ApiClientError) {
        self.id = application.registrationApplication.id
        
        if let published = application.registrationApplication.publishedAt ?? application.registrationApplication.published {
            self.created = published
        } else {
            throw .responseMissingRequiredData("LemmyRegistrationApplication published")
        }
        
        self.questionResponse = application.registrationApplication.answer
        self.email = application.creatorLocalUser.email
        self.showNsfw = application.creatorLocalUser.showNsfw
        self.emailVerified = application.creatorLocalUser.emailVerified
        self.creator = try .init(from: application.creator)
        if let resolver = application.admin {
            self.resolver = try .init(from: resolver)
        } else {
            self.resolver = nil
        }
        let resolution: RegistrationApplication.ResolutionState
        if application.creatorLocalUser.acceptedApplication {
            resolution = .approved
        } else if application.admin != nil {
            resolution = .denied(reason: application.registrationApplication.denyReason)
        } else {
            resolution = .unresolved
        }
        self.resolution = resolution
    }
}
