//
//  GuestAccount.swift
//  Mlem
//
//  Created by Sjmarf on 24/05/2024.
//

import Foundation
import MlemMiddleware
import Observation

@Observable
class GuestAccount: Account {
    static let tierNumber: Int = 1
    
    var storedAccount: StoredAccount
    let api: ApiClient
    
    var actorId: URL { storedAccount.actorId }
    var name: String { storedAccount.name }
    var storedNickname: String? {
        get { storedAccount.storedNickname }
        set(newValue) { storedAccount.storedNickname = newValue }
    }

    var cachedSiteVersion: SiteVersion? {
        get { storedAccount.cachedSiteVersion }
        set(newValue) { storedAccount.cachedSiteVersion = newValue }
    }

    var avatar: URL? {
        get { storedAccount.avatar }
        set(newValue) { storedAccount.avatar = newValue }
    }

    var lastUsed: Date? {
        get { storedAccount.lastUsed }
        set(newValue) { storedAccount.lastUsed = newValue }
    }
    
    init(storedAccount: StoredAccount) async {
        self.storedAccount = storedAccount
        self.api = await ApiClient.getApiClient(for: storedAccount.baseUrl, with: nil)
        await GuestAccountCache.main.put(self)
    }
    
    fileprivate init(url: URL) async {
        self.storedAccount = .init(
            actorId: url,
            id: -1, // dummy value
            name: url.host() ?? "unknown",
            baseUrl: url
        )
        self.api = await .getApiClient(for: url, with: nil)
    }
    
    static func getGuestAccount(url: URL) async -> GuestAccount {
        await GuestAccountCache.main.getAccount(url: url)
    }
    
    func update(instance: Instance3) {
        var shouldSave = false
        if avatar != instance.avatar {
            avatar = instance.avatar
            shouldSave = true
        }
        if cachedSiteVersion != instance.version {
            cachedSiteVersion = instance.version
            shouldSave = true
        }
        if shouldSave {
            AccountsTracker.main.saveAccounts(ofType: .guest)
        }
    }
    
    var isActive: Bool { AppState.main.guestSession === self }
    
    var isSaved: Bool {
        AccountsTracker.main.guestAccounts.contains(where: { $0 === self })
    }
    
    var nicknameSortKey: String { storedNickname ?? name }
    var instanceSortKey: String { host ?? "" }
    
    func resetStoredSettings(withSave: Bool = true) {
        storedNickname = nil
        if withSave {
            AccountsTracker.main.saveAccounts(ofType: .guest)
        }
    }
}

extension GuestAccount: CacheIdentifiable {
    var cacheId: Int { actorId.hashValue }
}

class GuestAccountCache: CoreCache<GuestAccount> {
    static let main: GuestAccountCache = .init()
    
    func getAccount(url: URL) async -> GuestAccount {
        if let account = await get(url.hashValue) {
            return account
        }
        let account = await GuestAccount(url: url)
        await put(account)
        return account
    }
}
