//
//  ActiveGuestAccount.swift
//  Mlem
//
//  Created by Sjmarf on 24/05/2024.
//

import Foundation
import MlemMiddleware
import Observation

@Observable
class ActiveGuestAccount: ActiveAccount {
    typealias AccountType = GuestAccount
    
    private(set) var account: GuestAccount
    private(set) var instance: Instance3?

    init(account: GuestAccount) {
        self.account = account
        
        Task {
            try await self.api.fetchSiteVersion(task: Task {
                let (_, instance) = try await self.api.getMyPerson()
                self.instance = instance
                self.account.update(instance: instance)
                return instance.version
            })
        }
    }
    
    convenience init(url: URL) {
        self.init(account: .init(url: url))
    }
    
    func deactivate() {
        account.logActivity()
        api.cleanCaches()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
    
    static func == (lhs: ActiveGuestAccount, rhs: ActiveGuestAccount) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
