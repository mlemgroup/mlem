//
//  AuthenticatedAccount.swift
//  Mlem
//
//  Created by Sjmarf on 24/05/2024.
//

import Foundation
import MlemMiddleware
import Observation

// TODO: need a StoredUserAccount that is codable but has no ApiClient; this can then have an async initializer. Remove the Codable conformance from Account.

@Observable
class UserAccount: Account, CommunityOrPersonStub {
    static let tierNumber: Int = 1
    static let identifierPrefix: String = "@"
    
    let actorId: URL
    let id: Int
    let api: ApiClient
    let name: String
    var storedNickname: String?
    var cachedSiteVersion: SiteVersion?
    var avatar: URL?
    var lastUsed: Date?
    
    init(person: Person4, instance: Instance3) {
        self.api = person.api
        self.id = person.id
        self.name = person.name
        self.actorId = person.actorId
        self.storedNickname = nil
        self.cachedSiteVersion = instance.version
        self.avatar = person.avatar
        self.lastUsed = .now
    }
    
    enum CodingKeys: String, CodingKey {
        // These key names don't match the identifiers of their corresponding properties - this is because these key names must match the property names used in SavedAccount pre-1.3 in order to maintain compatibility
        case id, username, storedNickname, instanceLink, siteVersion, avatarUrl, lastUsed
    }
    
    enum DecodingError: Error {
        case cannotRemoveExtraneousPathComponents, noTokenInKeychain
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // copy simple values
        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .username)
        self.storedNickname = try values.decode(String?.self, forKey: .storedNickname)
        self.cachedSiteVersion = try values.decode(SiteVersion?.self, forKey: .siteVersion)
        self.avatar = try values.decode(URL?.self, forKey: .avatarUrl)
        self.lastUsed = try values.decode(Date?.self, forKey: .lastUsed)

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
        try container.encode(storedNickname, forKey: .storedNickname)
        try container.encode(cachedSiteVersion, forKey: .siteVersion)
        try container.encode(avatar, forKey: .avatarUrl)
        try container.encode(lastUsed, forKey: .lastUsed)
        try container.encode(api.baseUrl, forKey: .instanceLink)
    }
    
    var keychainId: String {
        getKeychainId(actorId: actorId)
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
            AccountsTracker.main.saveAccounts(ofType: .guest)
        }
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
    
    var isActive: Bool { AppState.main.activeSessions.contains(where: { $0 === self }) }
    
    var nicknameSortKey: String { nickname + (actorId.host() ?? "") }
    var instanceSortKey: String { (actorId.host() ?? "") + nickname }
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
