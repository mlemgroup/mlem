//
//  RegistrationApplicationCaches.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-01-12.
//

import Foundation

class RegistrationApplicationCache: ApiTypeBackedCache<RegistrationApplication, RegistrationApplicationSnapshot> {
    @MainActor
    override func performModelTranslation(
        api: ApiClient,
        from snapshot: RegistrationApplicationSnapshot
    ) -> RegistrationApplication {
        .init(
            api: api,
            id: snapshot.id,
            questionResponse: snapshot.questionResponse,
            creator: api.caches.person.getModel(api: api, from: .person1(snapshot.creator)),
            resolver: api.caches.person.getOptionalModel(api: api, from: .person1(snapshot.resolver)),
            email: snapshot.email,
            emailVerified: snapshot.emailVerified,
            showNsfw: snapshot.showNsfw,
            created: snapshot.created,
            resolution: snapshot.resolution
        )
    }
    
    @MainActor
    override func updateModel(
        _ item: RegistrationApplication,
        with snapshot: RegistrationApplicationSnapshot,
        semaphore: UInt? = nil
    ) {
        item.update(with: snapshot, semaphore: semaphore)
    }
}
