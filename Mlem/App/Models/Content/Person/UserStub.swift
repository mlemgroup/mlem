//
//  NewSavedUser.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation
import SwiftUI

enum UserError: Error {
    case noUserInResponse
}

@Observable
final class UserStub: UserProviding, Codable {
    var source: ApiClient { api }
    
    let instance: InstanceStub
    var caches: BaseCacheGroup { instance.caches }
    
    var stub: UserStub { self }
    
    @ObservationIgnored var api: ApiClient
    // @ObservationIgnored lazy var api: ApiClient = .init(baseUrl: instance.url, token: accessToken)
    
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
//    func makeActive() {
//        print("DEBUG making active with token \(accessToken)")
//        api.token = accessToken
//    }
    
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
    
    init(from response: ApiGetSiteResponse, instanceLink: URL, token: String) throws {
        guard let user = response.myUser else {
            throw UserError.noUserInResponse
        }
        print("DEBUG \(user.localUserView.localUser.id)")
        self.id = user.localUserView.localUser.id
        self.name = user.localUserView.person.name
        self.nickname = user.localUserView.person.displayName
        self.cachedSiteVersion = .init(response.version)
        self.avatarUrl = user.localUserView.person.avatar
        self.lastLoggedIn = Date.now
        
        self.instance = .createModel(url: instanceLink)
        self.actorId = parseActorId(instanceLink: response.actorId, name: name)
        self.accessToken = token
        self.api = .init(baseUrl: instanceLink, token: token)
        instance.api = api
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
        self.actorId = parseActorId(instanceLink: instanceLink, name: name)
        
        self.api = .init(baseUrl: instanceLink, token: "")
        
        // retrive token and update members
        self.accessToken = ""
        guard let token = AppConstants.keychain[keychainId] else {
            throw DecodingError.noTokenInKeychain
        }
        self.accessToken = token
        api.token = token
        
        print("DEBUG user \(id) has token \(accessToken)")
        
        // make sure instance uses the same (authenticated) API
        instance.api = api
        print("DEBUG instance token is \(instance.api.token)")
        print("DEBUG api token is \(api.token)")
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

private func parseActorId(instanceLink: URL, name: String) -> URL {
    var actorComponents = URLComponents(url: instanceLink, resolvingAgainstBaseURL: false)!
    actorComponents.path = "/u/\(name)"
    return actorComponents.url!
}
