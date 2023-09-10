//
//  AccountsPage.swift
//  Mlem
//
//  Created by David Bureš on 27.03.2022.
//

import Dependencies
import SwiftUI

struct AccountsPage: View {
    @Dependency(\.accountsTracker) var accountsTracker
    
    @Environment(\.setAppFlow) private var setFlow
    
    @EnvironmentObject var appState: AppState
    
    @State private var isShowingInstanceAdditionSheet: Bool = false
    
    @State var accountForDeletion: SavedAccount?
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        let instances = Array(accountsTracker.accountsByInstance.keys).sorted()
        
        Group {
            if instances.isEmpty || isShowingInstanceAdditionSheet {
                AddSavedInstanceView(onboarding: false)
            } else {
                List {
                    ForEach(instances, id: \.self) { instance in
                        Section(header: Text(instance)) {
                            ForEach(accountsTracker.accountsByInstance[instance] ?? []) { account in
                                Button(account.username) {
                                    dismiss()
                                    setFlow(using: account)
                                }
                                .swipeActions {
                                    Button("Remove", role: .destructive) {
                                        dismiss()
                                        accountsTracker.removeAccount(account: account)
                                        if account == appState.currentActiveAccount {
                                            // if we just deleted the current account we (currently!) have a decision to make
                                            if let first = accountsTracker.savedAccounts.first {
                                                // if we have another account available, go to that...
                                                
                                                // TODO: once onboarding is updated to support showing a user's
                                                // current accounts, we can scrap this and always go to onboarding.
                                                // This leaves the decision of which account to enter in the
                                                // user's hands, as opposed to us picking the first account with `.first`.
                                                setFlow(using: first)
                                            } else {
                                                // no accounts, so go to onboarding
                                                setFlow(using: nil)
                                            }
                                        }
                                    }
                                }
                                .foregroundColor(color(for: account))
                            }
                        }
                    }
                    
                    Button {
                        isShowingInstanceAdditionSheet = true
                    } label: {
                        Label("Add Account", systemImage: AppConstants.switchUserSymbolName)
                    }
                    .accessibilityLabel("Add a new account.")

                    if let account = appState.currentActiveAccount {
                        Button(role: .destructive) {
                            accountForDeletion = account
                        } label: {
                            Label("Delete Current Account", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingInstanceAdditionSheet) {
            AddSavedInstanceView(onboarding: false)
        }
        .sheet(item: $accountForDeletion) { account in
            DeleteAccountView(account: account)
        }
    }
    
    private func color(for account: SavedAccount) -> Color {
        guard let currentAccount = appState.currentActiveAccount else { return .primary }
        return account == currentAccount ? .secondary : .primary
    }
    
    private func setFlow(using account: SavedAccount?) {
        // this tiny delay prevents the modal dismiss animation from being cancelled
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            if let account {
                setFlow(.account(account))
                return
            }
            
            setFlow(.onboarding)
        }
    }
}
