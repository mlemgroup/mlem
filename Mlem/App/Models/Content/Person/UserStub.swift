//
//  NewSavedUser.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation
import SwiftUI

@Observable
final class UserStub: UserProviding, Codable {
    var source: ApiClient { api }
    
    let instance: InstanceStub
    var caches: BaseCacheGroup { instance.caches }
    
    var stub: UserStub { self }
    
    // @ObservationIgnored var api: ApiClient
    @ObservationIgnored lazy var api: ApiClient = .init(baseUrl: instance.url, token: accessToken)
    
    let id: Int
    let name: String
    var actorId: URL
    
    var accessToken: String
    var nickname: String?
    var cachedSiteVersion: SiteVersion?
    var avatarUrl: URL?
    var lastLoggedIn: Date?
    
    private var keychainId: String { "\(id)_accessToken" }
    
    // This should be called when the MyUser becomes the active account
    func makeActive() {
        print("MAKING ACTIVE WITH TOKEN \(accessToken)")
        api.token = accessToken
    }
    
    // This should be called when the MyUser becomes the inactive account
    func makeInactive() {
        // Clear the token to stop us accidentally making damaging API calls for whatever reason
        api.token = nil
    }
    
    enum CodingKeys: String, CodingKey {
        // These key names don't match the identifiers of their corresponding properties - this is because these key names must match the property names used in SavedAccount pre-1.3 in order to maintain compatibility
        case id, username, storedNickname, instanceLink, siteVersion, avatarUrl, lastUsed
    }
    
    enum DecodingError: Error {
        case noTokenInKeychain
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // copy simple values
        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .username)
        self.nickname = try values.decode(String?.self, forKey: .storedNickname)
        self.cachedSiteVersion = try values.decode(SiteVersion?.self, forKey: .siteVersion)
        self.avatarUrl = try values.decode(URL?.self, forKey: .avatarUrl)
        self.lastLoggedIn = try values.decode(Date?.self, forKey: .lastUsed)

        // parse instance link
        let instanceLink = try values.decode(URL.self, forKey: .instanceLink)
        // Remove the "api/v3" path that we attached to the instanceLink pre-1.3
        var components = URLComponents(url: instanceLink, resolvingAgainstBaseURL: false)!
        components.path = ""
        self.instance = .createModel(url: components.url!)
        
        // parse actor id
        var actorComponents = URLComponents(url: instanceLink, resolvingAgainstBaseURL: false)!
        actorComponents.path = "/u/\(name)"
        self.actorId = actorComponents.url!
        
        // retrive token and update members
        self.accessToken = ""
        guard let token = AppConstants.keychain[keychainId] else {
            throw DecodingError.noTokenInKeychain
        }
        self.accessToken = token
        instance.api = api
    }
    
    func encode(to encoder: Encoder) throws {
        AppConstants.keychain[keychainId] = accessToken
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .username)
        try container.encode(nickname, forKey: .storedNickname)
        try container.encode(cachedSiteVersion, forKey: .siteVersion)
        try container.encode(avatarUrl, forKey: .avatarUrl)
        try container.encode(lastLoggedIn, forKey: .lastUsed)
        try container.encode(instance.url, forKey: .instanceLink)
    }
}
