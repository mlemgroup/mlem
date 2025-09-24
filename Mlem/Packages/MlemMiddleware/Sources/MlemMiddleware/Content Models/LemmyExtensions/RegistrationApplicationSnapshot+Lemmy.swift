//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-09-24.
//

import Foundation

extension RegistrationApplicationSnapshot {
    init(from application: LemmyRegistrationApplicationView) throws(ApiClientError) {
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
