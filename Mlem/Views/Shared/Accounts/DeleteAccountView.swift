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
    @Dependency(\.accountsTracker) var accountsTracker
    
    @EnvironmentObject var appState: AppState
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.forceOnboard) var forceOnboard
    
    @Dependency(\.apiClient) private var apiClient
    @Dependency(\.errorHandler) var errorHandler
    
    @State private var password = ""
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Text("Really delete \(appState.currentActiveAccount.username)?")
                .font(.title)
                .fontWeight(.bold)
            
            // swiftlint:disable line_length
            Text("Please note that this will *permanently* remove it from \(appState.currentActiveAccount.hostName ?? "the instance"), not just Mlem!")
            // swiftlint:enable line_length
            
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
                try await apiClient.deleteUser(user: appState.currentActiveAccount, password: password)
                accountsTracker.removeAccount(
                    account: appState.currentActiveAccount,
                    appState: appState,
                    forceOnboard: forceOnboard
                )
            } catch {
                errorHandler.handle(.init(underlyingError: error))
            }
        }
    }
}
