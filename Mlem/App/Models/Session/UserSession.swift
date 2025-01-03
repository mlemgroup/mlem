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
    private(set) var blocks: BlockList?
    private(set) var unreadCount: UnreadCount?
    /// This **only** includes requests made by calling `toggleInstanceBlock` on this `UserSession`.
    private(set) var ongoingInstanceBlockRequests: Set<URL> = []
    private(set) var visitHistory: VisitHistory?

    init(account: UserAccount) {
        self.account = account
        self.subscriptions = api.setupSubscriptionList(
            getFavorites: { account.favorites },
            setFavorites: {
                account.favorites = $0
                AccountsTracker.main.saveAccounts(ofType: .user)
            }
        )
        
        Task { @MainActor in
            do {
                try await self.api.contextDataManager.getValue(task: Task {
                    let (person, instance, blocks) = try await self.api.getMyPerson()
                    if let person {
                        self.account.update(person: person, instance: instance)
                        self.person = person
                    }
                    self.blocks = blocks
                    self.instance = instance
                    return .init(instance: instance, person: person)
                })
                
                try await self.api.getSubscriptionList()
                
                self.unreadCount = try await api.getUnreadCount()
            } catch {
                handleError(error)
            }
            if account.visitHistoryEnabled {
                do {
                    self.visitHistory = try await PersistenceRepository.liveValue.loadVisitHistory(for: account)
                } catch {
                    self.visitHistory = .init()
                    handleError(error)
                }
            }
        }
    }
    
    func deactivate() {
        account.logActivity()
        api.cleanCaches()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(api)
    }
    
    static func == (lhs: UserSession, rhs: UserSession) -> Bool {
        lhs.api == rhs.api
    }
    
    func saveVisitHistory() async throws {
        if let visitHistory {
            try await PersistenceRepository.liveValue.saveVisitHistory(visitHistory, for: account)
        }
    }

    func toggleInstanceBlock(actorId: URL) {
        guard !ongoingInstanceBlockRequests.contains(actorId) else { return }
        ongoingInstanceBlockRequests.insert(actorId)
        Task(priority: .userInitiated) { @MainActor in
            var toastId: UUID?
            do {
                let instanceId: Int
                let shouldBlock: Bool
                if let id = self.blocks?.instanceIdOfBlockedInstance(actorId: actorId) {
                    instanceId = id
                    toastId = ToastModel.main.add(.loading("Unblocking..."))
                    shouldBlock = false
                } else {
                    let stub = InstanceStub(api: api, actorId: actorId)
                    toastId = ToastModel.main.add(.loading("Blocking..."))
                    instanceId = try await stub.upgrade().instanceId
                    shouldBlock = true
                }
                try await api.blockInstance(actorId: actorId, instanceId: instanceId, block: shouldBlock)
                if let toastId {
                    ToastModel.main.removeToast(id: toastId)
                }
                ToastModel.main.add(.success(shouldBlock ? "Blocked" : "Unblocked"))
            } catch {
                ToastModel.main.add(.failure())
                handleError(error)
            }
            ongoingInstanceBlockRequests.remove(actorId)
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
