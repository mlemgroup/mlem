//
//  RegistrationApplicationCaches.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-12.
//  

import Foundation

class RegistrationApplicationCache: ApiTypeBackedCache<RegistrationApplication, ApiRegistrationApplicationView> {
    @MainActor
    override func performModelTranslation(
        api: ApiClient,
        from apiType: ApiRegistrationApplicationView
    ) -> RegistrationApplication {
        let resolution: RegistrationApplication.ResolutionState
        if apiType.creatorLocalUser.acceptedApplication {
            resolution = .approved
        } else if apiType.admin != nil {
            resolution = .denied(reason: apiType.registrationApplication.denyReason)
        } else {
            resolution = .unresolved
        }
        
        return .init(
            api: api,
            id: apiType.registrationApplication.id,
            questionResponse: apiType.registrationApplication.answer,
            creator: api.caches.person1.getModel(api: api, from: apiType.creator),
            resolver: api.caches.person1.getOptionalModel(api: api, from: apiType.admin),
            email: apiType.creatorLocalUser.email,
            emailVerified: apiType.creatorLocalUser.emailVerified,
            showNsfw: apiType.creatorLocalUser.showNsfw,
            created: apiType.registrationApplication.published,
            resolution: resolution
        )
    }
    
    @MainActor
    override func updateModel(
        _ item: RegistrationApplication,
        with apiType: ApiRegistrationApplicationView,
        semaphore: UInt? = nil
    ) {
        item.update(with: apiType, semaphore: semaphore)
    }
}
