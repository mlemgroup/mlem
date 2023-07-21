//
//  App State.swift
//  Mlem
//
//  Created by David Bureš on 04.05.2023.
//

import Foundation
import Dependencies
import SwiftUI
import AlertToast

class AppState: ObservableObject {
    
    @Dependency(\.apiClient) var apiClient
    
    @AppStorage("defaultAccountId") var defaultAccountId: Int?
    @Binding private var selectedAccount: SavedAccount?
    @Published private(set) var currentActiveAccount: SavedAccount
    
    @Published var contextualError: ContextualError?
    
    // for those  messages that are less of a .alert ;)
    @Published var isShowingToast: Bool = false
    @Published var toast: AlertToast?

    @Published var enableDownvote: Bool = true
    
    /// Initialises our app state
    /// - Parameters:
    ///   - defaultAccount: The account the application should start with
    ///   - selectedAccount: A `Binding` to the selected account at the `Window` level
    init(defaultAccount: SavedAccount, selectedAccount: Binding<SavedAccount?>) {
        _selectedAccount = selectedAccount
        self.currentActiveAccount = defaultAccount
        defaultAccountId = currentActiveAccount.id
        accountUpdated()
    }
    
    func setActiveAccount(_ account: SavedAccount) {
        // update our stored token and set the account...
        AppConstants.keychain["\(account.id)_accessToken"] = account.accessToken
        self.currentActiveAccount = account
        defaultAccountId = currentActiveAccount.id

        // if the account we just set is not the existing one from the session
        // then the user is switching accounts, so we pass the value up to the
        // `Window` layer which will re-create our `ContentView` and the new
        // account will restart on the feed page with a clean slate
        if account.id != selectedAccount?.id {
            self.selectedAccount = account
            return
        }
        
        accountUpdated()
    }
    
    private func accountUpdated() {
        // ensure our client session is updated
        apiClient.configure(for: currentActiveAccount)
        
        Task {
            let request = GetSiteRequest(account: currentActiveAccount)
            if let response = try? await APIClient().perform(request: request) {
                await MainActor.run {
                    enableDownvote = response.siteView.localSite.enableDownvotes
                }
            }
        }
    }
}
