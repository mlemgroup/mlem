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
class UserAccount: Account, CommunityOrPersonStub {
    static let tierNumber: Int = 1
    static let identifierPrefix: String = "@"
    
    var storedAccount: StoredAccount
    let api: ApiClient
    
    var actorId: URL { storedAccount.actorId }
    var id: Int { storedAccount.id }
    var name: String { storedAccount.name }
    var storedNickname: String? {
        get { storedAccount.storedNickname }
        set(newValue) { storedAccount.storedNickname = newValue }
    }

    var cachedSiteVersion: SiteVersion? {
        get { storedAccount.cachedSiteVersion }
        set(newValue) { storedAccount.cachedSiteVersion = newValue }
    }

    var avatar: URL? {
        get { storedAccount.avatar }
        set(newValue) { storedAccount.avatar = newValue }
    }

    var lastUsed: Date? {
        get { storedAccount.lastUsed }
        set(newValue) { storedAccount.lastUsed = newValue }
    }
    
    init(person: Person4, instance: Instance3) {
        self.api = person.api
        self.storedAccount = .init(
            actorId: person.actorId,
            id: person.id,
            name: person.name,
            storedNickname: nil,
            avatar: person.avatar,
            baseUrl: person.api.baseUrl
        )
    }
    
    init(storedAccount: StoredAccount) async throws {
        self.storedAccount = storedAccount
        
        // retrive token and initialize ApiClient
        guard let token = AppConstants.keychain[getKeychainId(actorId: storedAccount.actorId)]
            ?? AppConstants.keychain[getKeychainId(id: storedAccount.id)] else {
            throw AccountError.noTokenInKeychain
        }
        
        self.api = await ApiClient.getApiClient(for: storedAccount.baseUrl, with: token)
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
    
    func updateToken(_ newToken: String) async {
        await api.updateToken(newToken)
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
