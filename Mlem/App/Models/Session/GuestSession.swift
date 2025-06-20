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
        account.activate()
        
        Task {
            let instance = try await self.api.getMyInstance()
            let software = try await self.api.software
            await self.account.update(instance: instance, software: software)
            self.instance = instance
        }
    }
    
    convenience init(url: URL) throws {
        try self.init(account: .getGuestAccount(url: url))
    }
    
    func deactivate() {
        account.deactivate()
        api.cleanCaches()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
    
    static func == (lhs: GuestSession, rhs: GuestSession) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
