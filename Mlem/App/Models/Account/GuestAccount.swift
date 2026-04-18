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
    let actorId: ActorIdentifier
    let api: ApiClient
    var storedNickname: String?
    var siteSoftware: SiteSoftware?
    var avatar: URL?
    var activityState: AccountActivityState
    let accountType: AccountType = .guest
    
    fileprivate init(url: URL) throws {
        guard let host = url.host() else { throw DecodingError.invalidHost }
        self.actorId = .instance(host: host)
        self.activityState = .inactive(lastUsed: nil)
        self.api = .getApiClient(url: url, username: nil)
    }
  
    // TODO: updated mocks
//    #if DEBUG
//        private init(api: MockApiClient) {
//            self.actorId = api.actorId
//            self.activityState = .inactive(lastUsed: nil)
//            self.api = api
//        }
//    
//        static func mock(api: MockApiClient) -> GuestAccount { .init(api: api) }
//    #endif
    
    static func getGuestAccount(url: URL) throws -> GuestAccount {
        try GuestAccountCache.main.getAccount(url: url)
    }
    
    enum CodingKeys: String, CodingKey {
        // Keys are named this way to be consistent with the `UserAccount.CodingKey` cases
        case storedNickname, instanceLink, siteVersion, avatarUrl, lastUsed, activityState, siteSoftware
    }
    
    enum DecodingError: Error {
        case invalidHost
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.storedNickname = try values.decode(String?.self, forKey: .storedNickname)
        
        if let siteSoftware = try values.decodeIfPresent(SiteSoftware.self, forKey: .siteSoftware) {
            self.siteSoftware = siteSoftware
        } else if let version = try values.decode(SiteVersion?.self, forKey: .siteVersion) {
            self.siteSoftware = .init(type: .lemmy, version: version)
        } else {
            self.siteSoftware = nil
        }
        
        self.avatar = try values.decode(URL?.self, forKey: .avatarUrl)
        
        if let activityState = try values.decodeIfPresent(AccountActivityState.self, forKey: .activityState) {
            self.activityState = activityState
        } else {
            let lastUsed = try values.decodeIfPresent(Date?.self, forKey: .lastUsed) ?? nil
            self.activityState = .inactive(lastUsed: lastUsed)
        }

        let actorId = try values.decode(ActorIdentifier.self, forKey: .instanceLink)
        self.actorId = actorId
        self.api = ApiClient.getApiClient(url: actorId.url, username: nil)
        GuestAccountCache.main.itemCache.put(self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(storedNickname, forKey: .storedNickname)
        try container.encode(siteSoftware, forKey: .siteSoftware)
        try container.encode(avatar, forKey: .avatarUrl)
        try container.encode(activityState, forKey: .activityState)
        try container.encode(api.baseUrl, forKey: .instanceLink)
    }
    
    @MainActor
    func update(instance: Instance, software: SiteSoftware) {
        var shouldSave = false
        if avatar != instance.avatar {
            avatar = instance.avatar
            shouldSave = true
        }
        if siteSoftware != software {
            siteSoftware = software
            shouldSave = true
        }
        if shouldSave {
            AccountsTracker.main.saveAccounts(ofType: .guest)
        }
    }
    
    var name: String { actorId.host }
    
    var isActive: Bool { AppState.main.guestSession === self }
    
    var isSaved: Bool {
        AccountsTracker.main.guestAccounts.contains(where: { $0 === self })
    }
    
    var nicknameSortKey: String { storedNickname ?? name }
    var instanceSortKey: String { host }
    
    var uniqueStringId: String { host }
    
    func resetStoredSettings(withSave: Bool = true) {
        storedNickname = nil
        if withSave {
            AccountsTracker.main.saveAccounts(ofType: .guest)
        }
    }
    
    func setNickname(_ newValue: String) {
        storedNickname = newValue.isEmpty ? nil : newValue
        AccountsTracker.main.saveAccounts(ofType: .guest)
    }
    
    var profileCreated: Date? { nil }
    var description: String? { nil }
    var banner: URL? { nil }
    var updated: Date? { nil }
}

extension GuestAccount: CacheIdentifiable {
    var cacheId: Int { actorId.hashValue }
}

class GuestAccountCache: CoreCache<GuestAccount> {
    static let main: GuestAccountCache = .init()
    
    func getAccount(url: URL) throws -> GuestAccount {
        if let account = retrieveModel(cacheId: url.hashValue) {
            return account
        }
        let account = try GuestAccount(url: url)
        itemCache.put(account)
        return account
    }
}
