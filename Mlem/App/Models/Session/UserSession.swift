//
//  UserSession.swift
//  Mlem
//
//  Created by Sjmarf on 24/05/2024.
//

import Foundation
import MlemMiddleware
import Observation

@Observable
class UserSession: Session {
    typealias AccountType = UserAccount
    
    private(set) var account: UserAccount
    
    private(set) var person: Person4?
    private(set) var instance: Instance3?
    private(set) var subscriptions: SubscriptionList!
    private(set) var unreadCount: UnreadCount?
    
    // TODO: Store this in a file; make sure to translate 1.0 favorites to 2.0 favorites
    private var favorites: Set<Int> = []

    init(account: UserAccount) {
        self.account = account
        api.permissions = .all
        self.subscriptions = api.setupSubscriptionList(
            getFavorites: { self.favorites },
            setFavorites: { self.favorites = $0 }
        )
        
        Task {
            do {
                try await self.api.fetchSiteVersion(task: Task {
                    let (person, instance, _) = try await self.api.getMyPerson()
                    if let person {
                        self.account.update(person: person, instance: instance)
                        self.person = person
                    }
                    self.instance = instance
                    return instance.version
                })
                
                try await self.api.getSubscriptionList()
                
                self.unreadCount = try await api.getUnreadCount()
            } catch {
                handleError(error)
            }
        }
    }
    
    func deactivate() {
        account.logActivity()
        api.permissions = .getOnly
        api.cleanCaches()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
    
    static func == (lhs: UserSession, rhs: UserSession) -> Bool {
        lhs.actorId == rhs.actorId
    }
}
