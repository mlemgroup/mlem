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

    init(account: UserAccount) {
        self.account = account
        self.subscriptions = api.setupSubscriptionList(
            getFavorites: { account.favorites },
            setFavorites: {
                account.favorites = $0
                AccountsTracker.main.saveAccounts(ofType: .user)
            }
        )
        
        Task {
            do {
                try await self.api.fetchSiteVersion(task: Task {
                    let (person, instance, blocks) = try await self.api.getMyPerson()
                    if let person {
                        self.account.update(person: person, instance: instance)
                        self.person = person
                    }
                    self.blocks = blocks
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
        api.cleanCaches()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(api)
    }
    
    static func == (lhs: UserSession, rhs: UserSession) -> Bool {
        lhs.api == rhs.api
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
}
