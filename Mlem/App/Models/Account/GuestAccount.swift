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
    init(storedAccount: StoredAccount) async throws {
        try await super.init(storedAccount: storedAccount, token: nil)
        await GuestAccountCache.main.put(self)
    }
    
    fileprivate init(url: URL) async {
        await super.init(
            storedAccount: .init(
                actorId: url,
                id: -1, // dummy value
                name: url.host() ?? "unknown",
                baseUrl: url
            ),
            api: .getApiClient(for: url, with: nil)
        )
    }
  
    /// Bootstrap initializer to provide synchronous access to a default guest account
    fileprivate init() {
        let newApi = ApiClient.bootstrapApiClient()
        super.init(
            storedAccount: .init(
                actorId: newApi.baseUrl,
                id: -1, // dummy value
                name: newApi.baseUrl.host() ?? "unknown",
                baseUrl: newApi.baseUrl
            ),
            api: newApi
        )
        
        Task {
            await GuestAccountCache.main.put(self)
        }
    }
    
    static func getDefaultGuestAccount() -> GuestAccount { .init() }
    
    static func getGuestAccount(url: URL) async -> GuestAccount {
        await GuestAccountCache.main.getAccount(url: url)
    }
    
    func update(instance: Instance3) async {
        var shouldSave = false
        if avatar != instance.avatar {
            await setAvatar(instance.avatar)
            shouldSave = true
        }
        if cachedSiteVersion != instance.version {
            await setCachedSiteVersion(instance.version)
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
    
    func resetStoredSettings(withSave: Bool = true) async {
        await setStoredNickname(nil)
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
