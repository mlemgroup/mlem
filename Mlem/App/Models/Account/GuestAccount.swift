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
    let actorId: URL
    let api: ApiClient
    var storedNickname: String?
    var cachedSiteVersion: SiteVersion?
    var avatar: URL?
    var lastUsed: Date?
    
    fileprivate init(url: URL) {
        self.actorId = url
        self.api = .getApiClient(for: url, with: nil)
    }
    
    static func getGuestAccount(url: URL) -> GuestAccount {
        GuestAccountCache.main.getAccount(url: url)
    }
    
    enum CodingKeys: String, CodingKey {
        // Keys are named this way to be consistent with the `UserAccount.CodingKey` cases
        case storedNickname, instanceLink, siteVersion, avatarUrl, lastUsed
    }
    
    enum DecodingError: Error {
        case cannotRemoveExtraneousPathComponents, noTokenInKeychain
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.storedNickname = try values.decode(String?.self, forKey: .storedNickname)
        self.cachedSiteVersion = try values.decode(SiteVersion?.self, forKey: .siteVersion)
        self.avatar = try values.decode(URL?.self, forKey: .avatarUrl)
        self.lastUsed = try values.decode(Date?.self, forKey: .lastUsed)

        let instanceLink = try values.decode(URL.self, forKey: .instanceLink)
        self.actorId = instanceLink
        
        self.api = ApiClient.getApiClient(for: instanceLink, with: nil)
        GuestAccountCache.main.itemCache.put(self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(storedNickname, forKey: .storedNickname)
        try container.encode(cachedSiteVersion, forKey: .siteVersion)
        try container.encode(avatar, forKey: .avatarUrl)
        try container.encode(lastUsed, forKey: .lastUsed)
        try container.encode(api.baseUrl, forKey: .instanceLink)
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
    
    var name: String {
        actorId.host() ?? "unknown"
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
    
    func getAccount(url: URL) -> GuestAccount {
        if let account = retrieveModel(cacheId: url.hashValue) {
            return account
        }
        let account = GuestAccount(url: url)
        itemCache.put(account)
        return account
    }
}
