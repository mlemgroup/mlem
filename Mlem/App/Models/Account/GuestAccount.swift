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
    let actorId: URL
    let api: ApiClient
    var storedNickname: String?
    var cachedSiteVersion: SiteVersion?
    var avatar: URL?
    var lastUsed: Date?
    
    init(url: URL) {
        self.actorId = url
        self.api = .getApiClient(for: url, with: nil)
    }
    
    init(instance: Instance3) {
        self.api = instance.guestApi
        self.actorId = instance.actorId
        self.storedNickname = nil
        self.cachedSiteVersion = instance.version
        self.avatar = instance.avatar
        self.lastUsed = .now
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
            AccountsTracker.main.saveAccounts()
        }
    }
    
    var name: String {
        actorId.host() ?? "unknown"
    }
    
    var isActive: Bool { AppState.main.guestAccount === self }
    
    var nicknameSortKey: String { storedNickname ?? name }
    var instanceSortKey: String { host ?? "" }
}
