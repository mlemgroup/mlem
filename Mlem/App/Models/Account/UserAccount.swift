//
//  AuthenticatedAccount.swift
//  Mlem
//
//  Created by Sjmarf on 24/05/2024.
//

import Foundation
import MlemMiddleware
import Observation

@Observable
class UserAccount: Account, CommunityOrPerson {
    static var identifierPrefix: String = "@"
    
    let actorId: ActorIdentifier
    let id: Int
    let api: ApiClient
    let name: String
    var storedNickname: String?
    var siteSoftware: SiteSoftware?
    var avatar: URL?
    var activityState: AccountActivityState
    var favorites: Set<Int>
    var visitHistoryEnabled: Bool
    var accountType: AccountType
    var versionWarningIgnored: SiteVersion?
    var description: String?
    var banner: URL?
    var created: Date?
    var updated: Date?
    
    init(person: Person, siteSoftware: SiteSoftware) {
        self.api = person.api
        self.id = person.id
        self.name = person.name
        self.actorId = person.actorId
        self.storedNickname = nil
        self.siteSoftware = siteSoftware
        self.avatar = person.avatar
        self.activityState = .inactive(lastUsed: nil)
        self.favorites = []
        self.visitHistoryEnabled = true
        self.accountType = (person.moderatedCommunities.value_?.isEmpty ?? true) ? .user : .moderator
        self.versionWarningIgnored = nil
        self.description = person.description
        self.banner = person.banner
        self.created = person.created
        self.updated = person.updated
    }
    
    enum CodingKeys: String, CodingKey {
        // These key names don't match the identifiers of their corresponding properties - this is because these key names must match the property names used in SavedAccount pre-1.3 in order to maintain compatibility
        case id, username, storedNickname, instanceLink, siteVersion, avatarUrl, versionWarningIgnored
        case lastUsed, favorites, accountType, visitHistoryEnabled, activityState
        case siteSoftware
        case description, banner, created, updated
    }
    
    enum DecodingError: Error { case cannotModifyPathComponents, invalidHost, noTokenInKeychain }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // copy simple values
        self.id = try values.decode(Int.self, forKey: .id)
        let name = try values.decode(String.self, forKey: .username)
        self.name = name
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
        
        self.favorites = try values.decodeIfPresent(Set<Int>.self, forKey: .favorites) ?? []
        self.visitHistoryEnabled = try values.decodeIfPresent(Bool.self, forKey: .visitHistoryEnabled) ?? true
        self.accountType = try values.decodeIfPresent(AccountType.self, forKey: .accountType) ?? .user

        self.versionWarningIgnored = try values.decodeIfPresent(SiteVersion?.self, forKey: .versionWarningIgnored) ?? nil

        // parse instance link
        let instanceLink = try values.decode(URL.self, forKey: .instanceLink)
        // Remove the "api/v3" path that we attached to the instanceLink pre-2.0
        var components = URLComponents(url: instanceLink, resolvingAgainstBaseURL: false)!
        // Adding a slash is important! The API returns instance actor IDs with a trailing slash.
        components.path = "/"
        guard let instanceLink = components.url else { throw DecodingError.cannotModifyPathComponents }
        
        guard instanceLink.host != nil,
              let actorId = ActorIdentifier(url: instanceLink.appendingPathComponent("u/\(name)")) else {
            throw DecodingError.invalidHost
        }
        self.actorId = actorId
        
        self.api = ApiClient.getApiClient(url: instanceLink, username: name)
        do {
            let keychain = Constants.main.keychain
            let token = try keychain.get(getKeychainId(actorId: actorId)) ?? keychain.get(getKeychainId(id: id))
            if let token {
                api.updateToken(token)
            } else {
                handleError(DecodingError.noTokenInKeychain)
            }
        } catch {
            handleError(error)
        }
        
        self.description = try values.decodeIfPresent(String.self, forKey: .description)
        self.banner = try values.decodeIfPresent(URL.self, forKey: .banner)
        self.created = try values.decodeIfPresent(Date.self, forKey: .created)
        self.updated = try values.decodeIfPresent(Date.self, forKey: .updated)
    }
    
    func encode(to encoder: Encoder) throws {
        saveTokenToKeychain()
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .username)
        try container.encode(storedNickname, forKey: .storedNickname)
        try container.encode(siteSoftware, forKey: .siteSoftware)
        try container.encode(avatar, forKey: .avatarUrl)
        try container.encode(activityState, forKey: .activityState)
        try container.encode(api.baseUrl, forKey: .instanceLink)
        try container.encode(visitHistoryEnabled, forKey: .visitHistoryEnabled)
        try container.encode(accountType, forKey: .accountType)
        try container.encode(favorites, forKey: .favorites)
        try container.encode(description, forKey: .description)
        try container.encode(banner, forKey: .banner)
        try container.encode(created, forKey: .created)
        try container.encode(updated, forKey: .updated)
        try container.encode(versionWarningIgnored, forKey: .versionWarningIgnored)
    }
    
    var keychainId: String {
        getKeychainId(actorId: actorId)
    }
    
    @MainActor
    func update(person: Person, software: SiteSoftware) {
        var shouldSave = false
        if avatar != person.avatar {
            avatar = person.avatar
            shouldSave = true
        }
        if siteSoftware != software {
            siteSoftware = software
            shouldSave = true
        }
        
        let newAccountType: AccountType
        if person.isAdmin.value_ ?? false {
            newAccountType = .admin
        } else if !(person.moderatedCommunities.value_?.isEmpty ?? true) {
            newAccountType = .moderator
        } else {
            newAccountType = .user
        }
        if accountType != newAccountType {
            accountType = newAccountType
            shouldSave = true
        }
        if person.description != description {
            description = person.description
            shouldSave = true
        }
        if person.banner != banner {
            banner = person.banner
            shouldSave = true
        }
        if person.created != created {
            created = person.created
            shouldSave = true
        }
        if person.updated != updated {
            updated = person.updated
            shouldSave = true
        }
        
        if shouldSave {
            AccountsTracker.main.saveAccounts(ofType: .user)
        }
    }

    func updateSoftware(_ software: SiteSoftware) {
        if self.siteSoftware != software {
            self.siteSoftware = software
            AccountsTracker.main.saveAccounts(ofType: .user)
        }
    }

    func ignoreVersionWarning(_ ignore: Bool) {
        self.versionWarningIgnored = ignore ? self.siteSoftware?.version : nil
        AccountsTracker.main.saveAccounts(ofType: .user)
    }
    
    func updateToken(_ newToken: String) {
        api.updateToken(newToken)
    }
    
    func saveTokenToKeychain() {
        if let token = api.token {
            do {
                try Constants.main.keychain.set(token, key: getKeychainId(actorId: actorId))
            } catch {
                handleError(error)
            }
        }
    }
    
    func deleteTokenFromKeychain() {
        try? Constants.main.keychain.remove(getKeychainId(actorId: actorId))
        try? Constants.main.keychain.remove(getKeychainId(id: id))
    }
    
    var isActive: Bool { AppState.main.activeSessions.contains(where: { $0 === self }) }
    
    var nicknameSortKey: String { nickname + actorId.host }
    var instanceSortKey: String { actorId.host + nickname }
    
    var uniqueStringId: String {
        assert(fullName != nil)
        return fullName ?? ""
    }
    
    var fullName: String? { "\(name)@\(host)" }
    
    var fullNameWithPrefix: String? { "@\(name)@\(host)" }
    
    func setNickname(_ newValue: String) {
        storedNickname = newValue.isEmpty ? nil : newValue
        AccountsTracker.main.saveAccounts(ofType: .user)
    }
    
    var profileCreated: Date? { created }
}

private func getKeychainId(actorId: ActorIdentifier) -> String {
    // localhost sometimes has url "http://localhost:PORT" and sometimes "https://lemmy-alpha/beta/etc" [1], so replace any of that with simple "localhost"
    //
    // [1](https://join-lemmy.org/docs/contributors/02-local-development.html#tests)

    let keychainActorId = actorId.description.replacing(
        /https?:\/\/(lemmy-(alpha|beta|gamma|delta|epsilon)|127\.0\.0\.1:\d{4}|localhost:\d{4})/,
        with: "localhost"
    )
    return "\(keychainActorId)_accessToken"
}

private func getKeychainId(id: Int) -> String {
    "\(id)_accessToken"
}
