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
    static let identifierPrefix: String = "@"
    
    var id: Int { storedAccount.id }
    
    init(person: Person4, instance: Instance3) {
        super.init(
            storedAccount: .init(
                actorId: person.actorId,
                id: person.id,
                name: person.name,
                storedNickname: nil,
                avatar: person.avatar,
                baseUrl: person.api.baseUrl
            ),
            api: person.api
        )
    }
    
    init(storedAccount: StoredAccount) async throws {
        // retrive token and initialize ApiClient
        guard let token = AppConstants.keychain[getKeychainId(actorId: storedAccount.actorId)]
            ?? AppConstants.keychain[getKeychainId(id: storedAccount.id)] else {
            throw AccountError.noTokenInKeychain
        }
        
        try await super.init(storedAccount: storedAccount, token: token)
    }
    
    var keychainId: String {
        getKeychainId(actorId: actorId)
    }
    
    func update(person: Person4, instance: Instance3) async {
        var shouldSave = false
        if avatar != person.avatar {
            await setAvatar(person.avatar)
            shouldSave = true
        }
        if cachedSiteVersion != instance.version {
            await setCachedSiteVersion(instance.version)
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
    
    override func getNicknameSortKey() -> String {
        nickname + (actorId.host() ?? "")
    }
    
    override func getInstanceSortKey() -> String {
        (actorId.host() ?? "") + nickname
    }
}

private func getKeychainId(actorId: URL) -> String {
    "\(actorId.absoluteString)_accessToken"
}

private func getKeychainId(id: Int) -> String {
    "\(id)_accessToken"
}
