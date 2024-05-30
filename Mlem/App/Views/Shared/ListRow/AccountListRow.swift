//
//  AccountListRow.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import Dependencies
import MlemMiddleware
import NukeUI
import SwiftUI

struct AccountListRow: View {
    @Environment(\.dismiss) private var dismiss
    
    @Environment(AppState.self) private var appState
    @Environment(NavigationLayer.self) private var navigation
    
    @State private var showingSignOutConfirmation: Bool = false
    
    let account: any Account
    var complications: Set<AccountListRowBody.Complication> = .withTime
    @Binding var isSwitching: Bool

    var body: some View {
        Button {
            if appState.firstSession.actorId != account.actorId {
                appState.changeAccount(to: account)
                if navigation.isInsideSheet {
                    dismiss()
                }
            }
        } label: {
            AccountListRowBody(account: account, complications: complications)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .swipeActions {
            if (account as? GuestAccount)?.isSaved ?? true {
                Button(signOutLabel) {
                    showingSignOutConfirmation = true
                }
                .tint(.red)
            }
        }
        .confirmationDialog(signOutPrompt, isPresented: $showingSignOutConfirmation) {
            Button(signOutLabel, role: .destructive) {
                if navigation.isInsideSheet, appState.activeSessions.contains(where: { $0.account === account }) {
                    dismiss()
                }
                account.signOut()
            }
        } message: {
            Text(signOutPrompt)
        }
    }
    
    var signOutLabel: String {
        account is UserAccount ? "Sign Out" : "Remove"
    }
    
    var signOutPrompt: String {
        if account is UserAccount {
            "Really sign out of \(account.nickname)?"
        } else {
            "Really remove \(account.nickname)?"
        }
    }
    
    var accessibilityLabel: String {
        var text: String
        if let account = account as? UserAccount {
            text = account.fullName ?? "unknown"
        } else {
            text = "guest"
        }
        
        if appState.firstSession.actorId == account.actorId {
            text += ", active"
        }
        return text
    }
}
