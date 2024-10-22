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

protocol Account: AnyObject, Codable, ActorIdentifiable, Profile1Providing, Hashable {
    // Stored
    var api: ApiClient { get }
    var name: String { get }
    var storedNickname: String? { get }
    var cachedSiteVersion: SiteVersion? { get }
    var avatar: URL? { get }
    var lastUsed: Date? { get set }
    var accountType: AccountType { get }
    
    // Computed
    var nickname: String { get }
    var nicknameSortKey: String { get }
    var instanceSortKey: String { get }
    var isActive: Bool { get }
}

// Profile1Providing conformance
extension Account {
    var blocked: Bool { false }
}

extension Account {
    func hash(into hasher: inout Hasher) {
        hasher.combine(actorId)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.actorId == rhs.actorId
    }
}

extension Account {
    func signOut() {
        AccountsTracker.main.removeAccount(account: self)
    }
    
    func logActivity() {
        lastUsed = .now
    }
    
    var nickname: String { storedNickname ?? name }
}
