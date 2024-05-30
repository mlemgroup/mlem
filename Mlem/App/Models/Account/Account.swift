//
//  NewSavedUser.swift
//  Mlem
//
//  Created by Sjmarf on 10/02/2024.
//

import Foundation
import KeychainAccess
import MlemMiddleware
import SwiftUI

enum UserError: Error {
    case noUserInResponse
    case unauthenticated
}

@Observable
final class Account: Codable, CommunityOrPersonStub, Profile1Providing {
    public static let tierNumber: Int = 1
    static let identifierPrefix: String = "@"
    
    var api: ApiClient
    
    let id: Int
    let name: String
    var actorId: URL
    
    var nickname: String?
    var cachedSiteVersion: SiteVersion?
    var avatar: URL?
    var lastLoggedIn: Date?
    
    enum CodingKeys: String, CodingKey {
        // These key names don't match the identifiers of their corresponding properties - this is because these key names must match the property names used in SavedAccount pre-1.3 in order to maintain compatibility
        case id, username, storedNickname, instanceLink, siteVersion, avatarUrl, lastUsed
    }
    
    enum DecodingError: Error {
        case noTokenInKeychain, cannotRemoveExtraneousPathComponents
    }
    
    init(
        api: ApiClient,
        id: Int,
        name: String,
        actorId: URL,
        nickname: String? = nil,
        cachedSiteVersion: SiteVersion? = nil,
        avatar: URL? = nil,
        lastLoggedIn: Date? = nil
    ) {
        self.api = api
        self.id = id
        self.name = name
        self.actorId = actorId
        self.nickname = nickname
        self.cachedSiteVersion = cachedSiteVersion
        self.avatar = avatar
        self.lastLoggedIn = lastLoggedIn
    }
    
    init(person: Person4, instance: Instance3) {
        self.api = person.api
        self.id = person.id
        self.name = person.name
        self.actorId = person.actorId
        self.nickname = nil
        self.cachedSiteVersion = instance.version
        self.avatar = person.avatar
        self.lastLoggedIn = .now
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // copy simple values
        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .username)
        self.nickname = try values.decode(String?.self, forKey: .storedNickname)
        self.cachedSiteVersion = try values.decode(SiteVersion?.self, forKey: .siteVersion)
        self.avatar = try values.decode(URL?.self, forKey: .avatarUrl)
        self.lastLoggedIn = try values.decode(Date?.self, forKey: .lastUsed)

        // parse instance link
        let instanceLink = try values.decode(URL.self, forKey: .instanceLink)
        // Remove the "api/v3" path that we attached to the instanceLink pre-2.0
        var components = URLComponents(url: instanceLink, resolvingAgainstBaseURL: false)!
        components.path = ""
        guard let instanceLink = components.url else { throw DecodingError.cannotRemoveExtraneousPathComponents }
        
        // parse actor id
        let actorId = parseActorId(instanceLink: instanceLink, name: name)
        self.actorId = actorId
        
        // retrive token and initialize ApiClient
        guard let token = AppConstants.keychain[getKeychainId(actorId: actorId)] ?? AppConstants.keychain[getKeychainId(id: id)] else {
            throw DecodingError.noTokenInKeychain
        }
        self.api = ApiClient.getApiClient(for: instanceLink, with: token)
    }
    
    func encode(to encoder: Encoder) throws {
        saveTokenToKeychain()
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .username)
        try container.encode(nickname, forKey: .storedNickname)
        try container.encode(cachedSiteVersion, forKey: .siteVersion)
        try container.encode(avatar, forKey: .avatarUrl)
        try container.encode(lastLoggedIn, forKey: .lastUsed)
        try container.encode(api.baseUrl, forKey: .instanceLink)
    }
    
    func update(person: Person4, instance: Instance3) {
        var shouldSave = false
        if avatar != person.avatar {
            avatar = person.avatar
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
    
    var keychainId: String {
        getKeychainId(actorId: actorId)
    }
    
    func updateToken(_ newToken: String) {
        api.updateToken(newToken)
    }
    
    func saveTokenToKeychain() {
        AppConstants.keychain[getKeychainId(actorId: actorId)] = api.token
    }
    
    func deleteTokenFromKeychain() {
        try? AppConstants.keychain.remove(getKeychainId(actorId: actorId))
        try? AppConstants.keychain.remove(getKeychainId(id: id))
    }
    
    func signOut() {
        AccountsTracker.main.removeAccount(account: self)
    }
    
    var nicknameSortKey: String {
        (nickname ?? name) + (host ?? "")
    }
    
    var instanceSortKey: String {
        (host ?? "") + (nickname ?? name)
    }
}

private func getKeychainId(actorId: URL) -> String {
    "\(actorId.absoluteString)_accessToken"
}

private func getKeychainId(id: Int) -> String {
    "\(id)_accessToken"
}

private func parseActorId(instanceLink: URL, name: String) -> URL {
    var actorComponents = URLComponents(url: instanceLink, resolvingAgainstBaseURL: false)!
    actorComponents.path = "/u/\(name)"
    return actorComponents.url!
}
