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
    
    private(set) var person: Person?
    private(set) var instance: Instance?
    private(set) var subscriptions: SubscriptionList!
    private(set) var blocks: BlockList?
    private(set) var unreadCount: UnreadCount?
    /// This **only** includes requests made by calling `toggleInstanceBlock` on this `UserSession`.
    private(set) var ongoingInstanceBlockRequests: Set<ActorIdentifier> = []
    private(set) var visitHistory: VisitHistory?
    
    private(set) var subscriptionListErrorDetails: ErrorDetails?

    init(account: UserAccount) {
        self.account = account
        account.activate()
        self.subscriptions = api.setupSubscriptionList(
            getFavorites: { account.favorites },
            setFavorites: {
                account.favorites = $0
                AccountsTracker.main.saveAccounts(ofType: .user)
            }
        )
        
        Task { @MainActor in
            do {
                let (person, instance, blocks) = try await self.api.getMyPerson()
                let software = try await self.api.software
                if let person {
                    self.account.update(person: person, software: software)
                    self.person = person
                }
                self.blocks = blocks
                self.instance = instance
            } catch {
                handleError(error)
            }
            
            do {
                self.unreadCount = try await api.getUnreadCount()
            } catch {
                handleError(error)
            }
            
            do {
                try await self.api.getSubscriptionList()
            } catch {
                self.subscriptionListErrorDetails = handleErrorWithDetails(error)
            }
            
            if account.visitHistoryEnabled {
                do {
                    self.visitHistory = try await PersistenceRepository.liveValue.loadVisitHistory(for: account)
                } catch {
                    self.visitHistory = .init()
                    try? await saveVisitHistory()
                    handleError(error, silent: true)
                }
            }
        }
    }
    
    func deactivate() {
        account.deactivate()
        api.cleanCaches()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(api)
    }
    
    static func == (lhs: UserSession, rhs: UserSession) -> Bool {
        lhs.api == rhs.api
    }
    
    func updateAccount() async throws {
        if let person, let instance {
            try await account.update(person: person, software: api.software)
        }
    }
    
    func saveVisitHistory() async throws {
        if let visitHistory {
            try await PersistenceRepository.liveValue.saveVisitHistory(visitHistory, for: account)
        }
    }

    func updateInstanceBlock(actorId: ActorIdentifier, shouldBlock: Bool, callback: ((Bool) -> Void)? = nil) {
        Task {
            guard !ongoingInstanceBlockRequests.contains(actorId) else {
                callback?(false)
                return
            }
            
            ongoingInstanceBlockRequests.insert(actorId)
            do {
                let instanceId: Int
                if let id = self.blocks?.instanceIdOfBlockedInstance(actorId: actorId) {
                    instanceId = id
                } else {
                    instanceId = try await api.getInstanceId(actorId: actorId)
                }
                try await api.blockInstance(url: actorId.url, instanceId: instanceId, block: shouldBlock)
                ongoingInstanceBlockRequests.remove(actorId)
                callback?(true)
            } catch {
                handleError(error)
                ongoingInstanceBlockRequests.remove(actorId)
                callback?(false)
            }
        }
    }
    
    @MainActor
    func setVisitHistoryEnabled(_ newValue: Bool) async throws {
        guard newValue != account.visitHistoryEnabled else { return }
        account.visitHistoryEnabled = newValue
        if newValue {
            visitHistory = .init()
        } else {
            visitHistory = nil
            try await PersistenceRepository.liveValue.saveVisitHistory(.init(), for: account)
        }
        AccountsTracker.main.saveAccounts(ofType: .user)
    }
}
