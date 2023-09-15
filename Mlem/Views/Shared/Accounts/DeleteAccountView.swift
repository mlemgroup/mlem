//
//  DeleteAccountView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-08-11.
//

import Dependencies
import Foundation
import SwiftUI

struct DeleteAccountView: View {
    @EnvironmentObject var appState: AppState // TODO: this is only needed while onboarding does not support existing accounts
    
    @Environment(\.setAppFlow) private var setFlow
    @Environment(\.dismiss) var dismiss
    
    @Dependency(\.accountsTracker) var accountsTracker: SavedAccountTracker
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.errorHandler) var errorHandler
    
    let account: SavedAccount
    
    @State private var password = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Really delete \(account.username)?")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Please note that this will *permanently* remove it from \(account.hostName ?? "the instance"), not just Mlem!")
            
            Text("To confirm, please enter your password:")
            
            SecureField("", text: $password)
                .padding(4)
                .background(Color.secondarySystemBackground)
                .cornerRadius(AppConstants.smallItemCornerRadius)
                .textContentType(.password)
                .submitLabel(.go)
                .onSubmit {
                    deleteAccount()
                }
            
            Button("Cancel") {
                dismiss()
            }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
    
    func deleteAccount() {
        Task {
            do {
                try await apiClient.deleteUser(user: account, password: password)
                accountsTracker.removeAccount(account: account)
                if account == appState.currentActiveAccount {
                    // if we just deleted the current account we (currently!) have a decision to make
                    if let first = accountsTracker.savedAccounts.first {
                        // if we have another account to go to do that...
                        // TODO: once onboarding is updated to support showing a users
                        // current accounts we can scrap this and always go to onboarding
                        // which leaves the decision of which account to re-enter as in the
                        // users hands as opposed to us picking one at random with `.first`.
                        setFlow(.account(first))
                    } else {
                        // no accounts, so go to onboarding
                        setFlow(.onboarding)
                    }
                }
            } catch {
                errorHandler.handle(.init(underlyingError: error))
            }
        }
    }
}
