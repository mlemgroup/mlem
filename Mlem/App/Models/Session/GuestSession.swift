//
//  GuestSession.swift
//  Mlem
//
//  Created by Sjmarf on 24/05/2024.
//

import Foundation
import MlemMiddleware
import Observation

@Observable
class GuestSession: Session {
    typealias AccountType = GuestAccount
    
    private(set) var account: GuestAccount
    private(set) var instance: Instance3?

    init(account: GuestAccount) {
        self.account = account
        
        Task {
            try await self.api.fetchSiteVersion(task: Task {
                let (_, instance, _) = try await self.api.getMyPerson()
                self.instance = instance
                Task { @MainActor in
                    self.account.update(instance: instance)
                }
                return instance.version
            })
        }
    }
    
    convenience init(url: URL) throws {
        try self.init(account: .getGuestAccount(url: url))
    }
    
    func deactivate() {
        account.logActivity()
        api.cleanCaches()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
    
    static func == (lhs: GuestSession, rhs: GuestSession) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
