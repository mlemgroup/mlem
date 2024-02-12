//
//  NewSavedUser.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation
import SwiftUI
import Dependencies

@Observable
final class AuthenticatedUserStub: AuthenticatedUserProviding, Codable {
    @Dependency(\.savedAccountTracker) var savedAccountTracker
    
    let instance: NewInstanceStub
    var caches: BaseCacheGroup { instance.caches }
    var actorId: URL { instance.actorId }
    
    @ObservationIgnored lazy var api: APIClient = {
        return .init(baseUrl: instance.url, token: accessToken)
    }()
    
    let id: Int
    let username: String
    
    let accessToken: String
    var nickname: String?
    var cachedSiteVersion: SiteVersion?
    var avatarUrl: URL?
    var lastLoggedIn: Date?
    
    enum CodingKeys: String, CodingKey {
        // These key names don't match the identifiers of their corresponding properties - this is because these key names must match the property names used in SavedAccount pre-1.3 in order to maintain compatibility
        case id, username, storedNickname, instanceLink, siteVersion, avatarUrl, lastUsed
    }
    
    enum DecodingError: Error {
        case noTokenInKeychain
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.username = try values.decode(String.self, forKey: .username)
        self.nickname = try values.decode(String?.self, forKey: .storedNickname)
        self.cachedSiteVersion = try values.decode(SiteVersion?.self, forKey: .siteVersion)
        self.avatarUrl = try values.decode(URL?.self, forKey: .avatarUrl)
        self.lastLoggedIn = try values.decode(Date?.self, forKey: .lastUsed)
        
        let instanceLink = try values.decode(URL.self, forKey: .instanceLink)
        // Remove the "api/v3" path that we attached to the instanceLink pre-1.3
        var components = URLComponents(url: account.instanceLink, resolvingAgainstBaseURL: false)!
        components.path = ""
        self.instance = .createModel(url: components.url!)
        
        guard let token = AppConstants.keychain["\(account.id)_accessToken"] else {
            throw DecodingError.noTokenInKeychain
        }
        self.accessToken = token
   }
    
    func encode(to encoder: Encoder) throws {
        AppConstants.keychain["\(account.id)_accessToken"] = accessToken
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(username, forKey: .username)
        try container.encode(nickname, forKey: .storedNickname)
        try container.encode(cachedSiteVersion, forKey: .siteVersion)
        try container.encode(cachedAvatarUrl, forKey: .avatarUrl)
        try container.encode(lastLoggedIn, forKey: .lastUsed)
        try container.encode(instanceLink, forKey: .instanceLink)
    }
}
