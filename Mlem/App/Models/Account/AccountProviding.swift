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

protocol AccountProviding: AnyObject, ContentStub, Profile1Providing {
    // Stored
    var name: String { get }
    var storedNickname: String? { get }
    var cachedSiteVersion: SiteVersion? { get }
    var avatar: URL? { get }
    var lastUsed: Date? { get }
    
    @MainActor func setLastUsed(_ newValue: Date)
    func getNicknameSortKey() -> String
    func getInstanceSortKey() -> String
    func isActive() -> Bool
}

extension AccountProviding {
    func signOut() async {
        await AccountsTracker.main.removeAccount(account: self)
    }
    
    func logActivity() async {
        await setLastUsed(.now)
    }
    
    var nickname: String { storedNickname ?? name }
}
