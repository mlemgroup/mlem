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

protocol Account: AnyObject, ContentStub, Profile1Providing {
    // Stored
    var name: String { get }
    var storedNickname: String? { get }
    var cachedSiteVersion: SiteVersion? { get }
    var avatar: URL? { get }
    var lastUsed: Date? { get set }
    
    // Computed
    var nickname: String { get }
    var nicknameSortKey: String { get }
    var instanceSortKey: String { get }
    var host: String? { get }
    var isActive: Bool { get }
}

extension Account {
    func signOut() async {
        await AccountsTracker.main.removeAccount(account: self)
    }
    
    func logActivity() {
        lastUsed = .now
    }
    
    var nickname: String { storedNickname ?? name }
}
