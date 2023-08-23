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
    @Binding private var selectedAccount: SavedAccount?
    @Published private(set) var currentActiveAccount: SavedAccount
    @Published private(set) var currentNickname: String
    
    @Published var enableDownvote: Bool = true
    
    /// Initialises our app state
    /// - Parameters:
    ///   - defaultAccount: The account the application should start with
    ///   - selectedAccount: A `Binding` to the selected account at the `Window` level
    init(defaultAccount: SavedAccount, selectedAccount: Binding<SavedAccount?>) {
        _selectedAccount = selectedAccount
        self.currentActiveAccount = defaultAccount
        self.currentNickname = defaultAccount.nickname
        self.defaultAccountId = currentActiveAccount.id
        accountUpdated()
    }
    
    func setActiveAccount(_ account: SavedAccount) {
        // update our stored token and set the account...
        AppConstants.keychain["\(account.id)_accessToken"] = account.accessToken
        currentActiveAccount = account
        defaultAccountId = currentActiveAccount.id

        // if the account we just set is not the existing one from the session
        // then the user is switching accounts, so we pass the value up to the
        // `Window` layer which will re-create our `ContentView` and the new
        // account will restart on the feed page with a clean slate
        if account.id != selectedAccount?.id {
            selectedAccount = account
            return
        }
        
        accountUpdated()
    }
    
    /**
     Update the nickname. This is needed to quickly propagate changes from settings over to the tab bar, since nickname doesn't affect account identity and so changing it doesn't always prompt redraws
     */
    func changeDisplayedNickname(to nickname: String) {
        currentNickname = nickname
    }
    
    private func accountUpdated() {
        // ensure our client session is updated
        apiClient.configure(for: currentActiveAccount)
        
        Task {
            if let response = try? await apiClient.loadSiteInformation() {
                await MainActor.run {
                    enableDownvote = response.siteView.localSite.enableDownvotes
                }
            }
        }
    }
}
