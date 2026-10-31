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
            properties: .init(api: api, snapshot: snapshot)
        )
    }
    
    @MainActor
    override func updateModel(
        _ item: RegistrationApplication,
        with snapshot: RegistrationApplicationSnapshot,
        semaphore: UInt? = nil
    ) {
        Task {
            await item.updateQueue.attemptDirectUpdate(with: .init(api: item.api, snapshot: snapshot))
        }
    }
}
