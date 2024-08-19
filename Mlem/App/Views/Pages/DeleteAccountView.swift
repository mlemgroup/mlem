//
//  DeleteAccountView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-08-19.
//

import Dependencies
import Foundation
import MlemMiddleware
import SwiftUI

struct DeleteAccountView: View {
    @Environment(AppState.self) var appState
    @Environment(Palette.self) var palette
    @Environment(\.dismiss) var dismiss
    
    let account: UserAccount
    
    @State private var password = ""
    @State var confirmed: Bool = false
    @State var deleteContent: Bool = true
    
    let deleteContentMinimumVersion: SiteVersion = .init("0.19.0")
    
    var body: some View {
        content
            .task {
                do {
                    try await account.api.fetchSiteVersion()
                } catch {
                    handleError(error)
                }
            }
    }
    
    var content: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Really delete \(account.name)?")
                .font(.title)
                .fontWeight(.bold)
            
            WarningView(
                iconName: Icons.warning,
                text: "This will permanently remove it from \(account.host ?? "the instance"), not just Mlem!",
                inList: false
            )
            
            deleteConfirmation
            
            Button("Cancel") {
                dismiss()
            }
        }
        .multilineTextAlignment(.center)
        .padding(Constants.main.standardSpacing)
    }
    
    @ViewBuilder
    var deleteConfirmation: some View {
        if confirmed {
            if let version = account.api.fetchedVersion {
                passwordPrompt(canDeleteContent: version >= deleteContentMinimumVersion)
            } else {
                VStack(spacing: Constants.main.standardSpacing) {
                    ProgressView()
                    Text("Loading instance details")
                        .foregroundStyle(palette.secondary)
                }
            }
        } else {
            Button("Permanently delete \(account.name)") {
                withAnimation {
                    confirmed = true
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
    }
    
    @ViewBuilder
    func passwordPrompt(canDeleteContent: Bool) -> some View {
        Text("To confirm, please enter your password:")
        
        Group {
            SecureField("", text: $password)
                .padding(4)
                .background(palette.secondaryBackground)
                .cornerRadius(Constants.main.smallItemCornerRadius)
                .textContentType(.password)
                .submitLabel(.go)
                .onSubmit {
                    deleteAccount(canDeleteContent: canDeleteContent)
                }
            
            if canDeleteContent {
                Toggle(isOn: $deleteContent) {
                    Text("Delete posts and comments")
                }
            }
        }
        .padding(.horizontal, 30)
    }
    
    func deleteAccount(canDeleteContent: Bool) {
        Task {
            do {
                try await account.api.deleteAccount(password: password, deleteContent: deleteContent)
            } catch {
                handleError(error)
            }
        }
//        Task {
//            do {
//                if canDeleteContent {
//                    try await apiClient.deleteUser(user: account, password: password, deleteContent: deleteContent)
//                } else {
//                    try await apiClient.legacyDeleteUser(user: account, password: password)
//                }
//                accountsTracker.removeAccount(account: account)
//                if account == appState.currentActiveAccount {
//                    // if we just deleted the current account we (currently!) have a decision to make
//                    if let first = accountsTracker.savedAccounts.first {
//                        // if we have another account to go to do that...
//                        // TODO: once onboarding is updated to support showing a users
//                        // current accounts we can scrap this and always go to onboarding
//                        // which leaves the decision of which account to re-enter as in the
//                        // users hands as opposed to us picking one at random with `.first`.
//                        setFlow(.account(first))
//                    } else {
//                        // no accounts, so go to onboarding
//                        setFlow(.onboarding)
//                    }
//                }
//            } catch {
//                errorHandler.handle(.init(underlyingError: error))
//            }
//        }
    }
}
