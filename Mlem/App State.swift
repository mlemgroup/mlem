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
    @Dependency(\.apiClient) var apiClient
    
    @AppStorage("defaultAccountId") var defaultAccountId: Int?
    
    @Published private(set) var currentActiveAccount: SavedAccount?
    @Published private(set) var currentNickname: String?
    
    /// A method to set the current active account
    /// - Important: If you wish to _clear_ the current active account please use the `\.setAppFlow` method available via the environment to reset to our `.onboarding` flow
    /// - Parameter account: The `SavedAccount` which should become the active account
    func setActiveAccount(_ account: SavedAccount) {
        AppConstants.keychain["\(account.id)_accessToken"] = account.accessToken
        // we configure the client here to ensure any updated session tokens are updated
        apiClient.configure(for: .account(account))
        currentActiveAccount = account
        currentNickname = account.nickname
        defaultAccountId = account.id
    }
    
    /// A method to clear the currentlly active account
    /// - Important: It is unlikely you will want to call this method directly but instead use the `\.setAppFlow` method available via the environment
    func clearActiveAccount() {
        currentActiveAccount = nil
        currentNickname = nil
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
