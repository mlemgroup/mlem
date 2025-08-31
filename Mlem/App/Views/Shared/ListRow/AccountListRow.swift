//
//  AccountListRow.swift
//  Mlem
//
//  Created by Sjmarf on 22/12/2023.
//

import Dependencies
import Icons
import MlemMiddleware
import NukeUI
import SwiftUI

struct AccountListRow: View {
    @Environment(\.dismiss) private var dismiss
    
    @Environment(AppState.self) private var appState
    @Environment(NavigationLayer.self) private var navigation
    @Setting(\.accounts_keepPlace) var keepPlace
    
    @State private var showingSignOutConfirmation: Bool = false
    
    let account: any Account
    var unreadCount: Int?
    var responseTime: TimeInterval?
    var complications: Set<AccountListRowBody.Complication> = .instanceAndTime
    @Binding var isSwitching: Bool
    
    var body: some View {
        Button {
            if appState.firstSession.actorId != account.actorId {
                changeAccount(keepPlace: keepPlace)
            }
        } label: {
            AccountListRowBody(
                account: account,
                unreadCount: unreadCount,
                responseTime: responseTime,
                complications: complications
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel)
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            if appState.firstSession.actorId != account.actorId {
                Group {
                    if keepPlace {
                        Button("Reload", icon: .lemmy.switchAccountAndReload) {
                            changeAccount(keepPlace: false)
                        }
                        .buttonStyle(.automatic)
                    } else {
                        Button("Keep Place", icon: .lemmy.switchAccountAndKeepPlace) {
                            changeAccount(keepPlace: true)
                        }
                        .buttonStyle(.automatic)
                    }
                }
                .tint(.blue)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            if (account as? GuestAccount)?.isSaved ?? true {
                Button(String(localized: signOutLabel)) {
                    showingSignOutConfirmation = true
                }
                .buttonStyle(.automatic)
                .tint(.red)
            }
        }
        .contextMenu {
            if (account as? GuestAccount)?.isSaved ?? true {
                SwiftUI.Section("Switch to this account and...") {
                    Button("Reload", icon: .lemmy.switchAccountAndReload) {
                        changeAccount(keepPlace: false)
                    }
                    Button("Keep Place", icon: .lemmy.switchAccountAndKeepPlace) {
                        changeAccount(keepPlace: true)
                    }
                }
                .disabled(appState.firstSession.actorId == account.actorId)
                Divider()
                Button(signOutLabel, icon: .general.signOut, role: .destructive) {
                    showingSignOutConfirmation = true
                }
            } else {
                Button("Keep", icon: .lemmy.addPin) {
                    AccountsTracker.main.addAccount(account: account)
                }
            }
        }
        .labelStyle(.titleAndIcon) // Override `.conditional` label style from parent view
        .confirmationDialog(String(localized: signOutPrompt), isPresented: $showingSignOutConfirmation) {
            Button(String(localized: signOutLabel), role: .destructive) {
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
    
    var signOutLabel: LocalizedStringResource {
        account is UserAccount ? "Sign Out" : "Remove"
    }
    
    var signOutPrompt: LocalizedStringResource {
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
