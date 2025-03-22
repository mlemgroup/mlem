//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-12.
//

import Foundation

extension RegistrationApplication: CacheIdentifiable {
    public var cacheId: Int { id }
    
    @MainActor
    func update(with applicationView: ApiRegistrationApplicationView, semaphore: UInt? = nil) {
        let resolution: RegistrationApplication.ResolutionState
        if applicationView.creatorLocalUser.acceptedApplication {
            resolution = .approved
        } else if applicationView.admin != nil {
            resolution = .denied(reason: applicationView.registrationApplication.denyReason)
        } else {
            resolution = .unresolved
        }
        
        setIfChanged(\.questionResponse, applicationView.registrationApplication.answer)
        resolutionManager.updateWithReceivedValue(resolution, semaphore: semaphore)
        setIfChanged(\.resolver, api.caches.person1.getOptionalModel(api: api, from: applicationView.admin))
        setIfChanged(\.email, applicationView.creatorLocalUser.email)
        setIfChanged(\.emailVerified, applicationView.creatorLocalUser.emailVerified)
        setIfChanged(\.showNsfw, applicationView.creatorLocalUser.showNsfw)
        creator.update(with: applicationView.creator)
    }
}
