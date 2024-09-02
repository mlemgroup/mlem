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
    @Setting(\.keepPlaceOnAccountSwitch) var keepPlace
    
    @State private var showingSignOutConfirmation: Bool = false
    
    let account: any Account
    var complications: Set<AccountListRowBody.Complication> = .withTime
    @Binding var isSwitching: Bool

    var body: some View {
        Button {
            if appState.firstSession.actorId != account.actorId {
                changeAccount(keepPlace: keepPlace)
            }
        } label: {
            AccountListRowBody(account: account, complications: complications)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if appState.firstSession.actorId != account.actorId {
                Group {
                    if keepPlace {
                        Button("Reload", systemImage: Icons.accountSwitchReload) {
                            changeAccount(keepPlace: false)
                        }
                    } else {
                        Button("Keep Place", systemImage: Icons.accountSwitchKeepPlace) {
                            changeAccount(keepPlace: true)
                        }
                    }
                }
                .tint(.blue)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if (account as? GuestAccount)?.isSaved ?? true {
                Button(signOutLabel) {
                    showingSignOutConfirmation = true
                }
                .tint(.red)
            }
        }
        .contextMenu {
            if (account as? GuestAccount)?.isSaved ?? true {
                SwiftUI.Section("Switch to this account and...") {
                    Button("Reload", systemImage: Icons.accountSwitchReload) {
                        changeAccount(keepPlace: false)
                    }
                    Button("Keep Place", systemImage: Icons.accountSwitchKeepPlace) {
                        changeAccount(keepPlace: true)
                    }
                }
                .disabled(appState.firstSession.actorId == account.actorId)
            } else {
                Button("Keep", systemImage: Icons.pin) {
                    AccountsTracker.main.addAccount(account: account)
                }
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
    
    func changeAccount(keepPlace: Bool) {
        appState.changeAccount(to: account, keepPlace: keepPlace)
        if navigation.isInsideSheet {
            if keepPlace {
                dismiss()
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
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
