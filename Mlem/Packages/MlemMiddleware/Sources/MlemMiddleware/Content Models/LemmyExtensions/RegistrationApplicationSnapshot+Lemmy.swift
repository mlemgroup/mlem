//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-09-24.
//

import Foundation

extension RegistrationApplicationSnapshot {
    init(from application: LemmyRegistrationApplicationView) throws(ApiClientError) {
        guard let published = application.registrationApplication.publishedAt ?? application.registrationApplication.published else {
            throw .responseMissingRequiredData("LemmyRegistrationApplication published")
        }
        
        let resolution: RegistrationApplication.ResolutionState
        if application.creatorLocalUser.acceptedApplication {
            resolution = .approved
        } else if application.admin != nil {
            resolution = .denied(reason: application.registrationApplication.denyReason)
        } else {
            resolution = .unresolved
        }

        try self.init(
            id: application.registrationApplication.id,
            created: published,
            questionResponse: application.registrationApplication.answer,
            email: application.creatorLocalUser.email,
            showNsfw: application.creatorLocalUser.showNsfw,
            creator: .init(from: application.creator),
            emailVerified: application.creatorLocalUser.emailVerified,
            resolver: application.admin.map { admin throws(ApiClientError) in try .init(from: admin) },
            resolution: resolution
        )
    }
}
