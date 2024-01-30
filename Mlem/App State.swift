//
//  App State.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Dependencies
import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Dependency(\.accountsTracker) var accountsTracker
    @Dependency(\.apiClient) var apiClient
    
    @AppStorage("defaultAccountId") var defaultAccountId: Int?
    @AppStorage("profileTabLabel") var profileTabLabel: ProfileTabLabel = .nickname
    @AppStorage("showUserAvatarOnProfileTab") var showUserAvatar: Bool = true
    
    @Published private(set) var currentActiveAccount: SavedAccount?
    
    /// A variable representing how the current account should be displayed in the tab bar
    var tabDisplayName: String {
        guard let currentActiveAccount else {
            return "Profile"
        }
        
        switch profileTabLabel {
        case .instance:
            return currentActiveAccount.hostName ?? "Instance"
        case .nickname:
            return currentActiveAccount.nickname
        case .anonymous:
            return "Profile"
        }
    }
    
    /// A variable representing the remote location to load the user profile avatar from if applicable
    var profileTabRemoteSymbolUrl: URL? {
        guard profileTabLabel != .anonymous, showUserAvatar else {
            return nil
        }
        
        return currentActiveAccount?.avatarUrl
    }
    
    /// A method to set the current active account, any changes to the account will be propogated to the persistence layer
    /// - Important: If you wish to _clear_ the current active account please use the `\.setAppFlow` method available via the environment to reset to our `.onboarding` flow
    /// - Parameter account: The `SavedAccount` which should become the active account
    func setActiveAccount(_ account: SavedAccount, saveChanges: Bool = true) {
        AppConstants.keychain["\(account.id)_accessToken"] = account.accessToken
        // we configure the client here to ensure any updated session tokens are updated
        apiClient.configure(for: .account(account))
        currentActiveAccount = account
        defaultAccountId = account.id
        if saveChanges {
            accountsTracker.update(with: account)
        }
    }
    
    /// A method to clear the currentlly active account
    /// - Important: It is unlikely you will want to call this method directly but instead use the `\.setAppFlow` method available via the environment
    func clearActiveAccount() {
        currentActiveAccount = nil
    }
    
    func isCurrentAccountId(_ id: Int) -> Bool {
        guard let currentActiveAccount else { return false }
        // TODO: we likely need to improve this check as comparing just the id might not be enough (same id, different instances)
        // I'm going to leave this for now as if we wanted to move to using a value like `.actorId` then we'll need to
        // to start storing it in the `SavedAccount` object first etc, which is getting well outside the scope of this PR...
        // although the _check_ has moved in this PR, it's performing the same check that was being done elsewhere so there
        // should be no regression introduced by only checking the `.id`
        return currentActiveAccount.id == id
    }
}
