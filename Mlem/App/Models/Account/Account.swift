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
    var siteSoftware: SiteSoftware? { get }
    var avatar: URL? { get }
    var activityState: AccountActivityState { get set }
    var accountType: AccountType { get }
    
    // Computed
    var nickname: String { get }
    var nicknameSortKey: String { get }
    var instanceSortKey: String { get }
    var isActive: Bool { get }
    var uniqueStringId: String { get }
    
    func setNickname(_ newValue: String)
}

enum AccountActivityState: Codable, Hashable {
    case inactive(lastUsed: Date?)
    case active
    
    var lastUsed: Date? {
        switch self {
        case let .inactive(lastUsed: lastUsed): lastUsed
        case .active: nil
        }
    }
}

// Profile1Providing conformance
extension Account {
    var blockedValue: Bool { false }
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
    
    func activate() {
        activityState = .active
    }
    
    func deactivate() {
        activityState = .inactive(lastUsed: .now)
    }
    
    var nickname: String { storedNickname ?? name }
}
