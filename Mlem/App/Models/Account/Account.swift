//
//  Account.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-06-14.
//

import Foundation
import MlemMiddleware
import Observation

@Observable
class Account: AccountProviding {
    static let tierNumber: Int = 1
    
    var storedAccount: StoredAccount
    var api: ApiClient
    
    var actorId: URL { storedAccount.actorId }
    
    var name: String { storedAccount.name }
    var storedNickname: String? { storedAccount.storedNickname }
    var cachedSiteVersion: SiteVersion? { storedAccount.cachedSiteVersion }
    var avatar: URL? { storedAccount.avatar }
    var lastUsed: Date? { storedAccount.lastUsed }
    
    func getNicknameSortKey() -> String {
        storedNickname ?? name
    }
    
    func getInstanceSortKey() -> String {
        host ?? ""
    }
    
    func isActive() -> Bool {
        preconditionFailure("This method must be implemented by the inheriting class")
    }
    
    @MainActor func setStoredNickname(_ newValue: String?) {
        storedAccount.storedNickname = newValue
    }
    
    @MainActor func setCachedSiteVersion(_ newValue: SiteVersion?) {
        storedAccount.cachedSiteVersion = newValue
    }
    
    @MainActor func setAvatar(_ newValue: URL?) {
        storedAccount.avatar = newValue
    }
    
    @MainActor func setLastUsed(_ newValue: Date) {
        storedAccount.lastUsed = newValue
    }
    
    init(storedAccount: StoredAccount, token: String?) async throws {
        self.storedAccount = storedAccount
        self.api = await ApiClient.getApiClient(for: storedAccount.baseUrl, with: token)
    }
    
    init(storedAccount: StoredAccount, api: ApiClient) {
        self.storedAccount = storedAccount
        self.api = api
    }
}
