//
//  AccountSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 09/05/2024.
//

import SwiftUI
import Theming

struct AccountSettingsView: View {
    @Environment(AppState.self) var appState
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.dismiss) var dismiss
    
    @State private var showingSignOutConfirmation: Bool = false
    
    var body: some View {
        Form {
            // empty section disables background
            Section {} header: {
                Group {
                    if let userAccount = appState.firstSession as? UserSession {
                        ProfileHeaderView(userAccount.person)
                    } else {
                        ProfileHeaderView(appState.firstSession.instance)
                    }
                }
                .foregroundStyle(.themedPrimary) // override default .secondary style
            }
            .textCase(nil) // override default all-caps
            .listRowInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
            
            if appState.firstSession is UserSession {
                Section {
                    NavigationLink(
                        "My Profile",
                        icon: .lemmy.person,
                        destination: .settings(.profile)
                    )
                    .gradientTint(.themedColorfulAccent(5))
                    if appState.firstAccount.siteSoftware?.supports(.editAccountSettings) ?? false {
                        NavigationLink(
                            "Sign-In & Security",
                            icon: .general.security,
                            destination: .settings(.accountSignIn)
                        )
                        .gradientTint(.themedColorfulAccent(2))
                        NavigationLink(
                            "Content & Notifications",
                            icon: .lemmy.post,
                            destination: .settings(.accountContent)
                        )
                        .gradientTint(.themedColorfulAccent(0))
                        NavigationLink(
                            "Advanced",
                            icon: .settings.advanced,
                            destination: .settings(.accountAdvanced)
                        )
                        .gradientTint(.themedNeutralAccent)
                    }
                }
                Section {
                    NavigationLink(
                        "Block List",
                        icon: .lemmy.block,
                        destination: .blockList
                    )
                    .gradientTint(.themedNegative)
                }
                Section {
                    NavigationLink(
                        "Local Options",
                        icon: .settings.localAccountOptions,
                        destination: .settings(.accountLocal)
                    )
                    .gradientTint(.themedColorfulAccent(2))
                } footer: {
                    Text("These options are stored locally in Mlem and not on your Lemmy account.")
                }
            } else {
                AccountNicknameFieldView()
            }
            
            Group {
                Section {
                    Button {
                        appState.firstAccount.signOut()
                    } label: {
                        Text(signOutLabel)
                            .frame(maxWidth: .infinity)
                    }
                    .confirmationDialog(String(localized: signOutPrompt), isPresented: $showingSignOutConfirmation) {
                        Button(String(localized: signOutLabel), role: .destructive) {
                            appState.firstAccount.signOut()
                        }
                    } message: {
                        Text(signOutPrompt)
                    }
                }
                
                if let account = appState.firstAccount as? UserAccount {
                    Section {
                        Button(role: .destructive) {
                            navigation.openSheet(.deleteAccount(account))
                        } label: {
                            Text("Delete Account")
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .tint(.themedWarning)
        }
        .labelStyle(.squircle)
        .navigationTitle(Text("Account"))
    }
    
    var title: String {
        if let userAccount = appState.firstSession as? UserSession {
            return userAccount.person?.displayName ?? "Account"
        } else {
            return appState.firstSession.instance?.displayName ?? "User"
        }
    }
    
    var subtitle: String {
        if let userAccount = appState.firstSession as? UserSession {
            return userAccount.person?.fullNameWithPrefix ?? "Loading..."
        }
        return appState.firstSession.instance?.name ?? "Loading..."
    }
    
    var signOutLabel: LocalizedStringResource {
        appState.firstAccount is UserAccount ? "Sign Out" : "Remove"
    }
    
    var signOutPrompt: LocalizedStringResource {
        if appState.firstAccount is UserAccount {
            "Really sign out of \(appState.firstAccount.nickname)?"
        } else {
            "Really remove \(appState.firstAccount.nickname)?"
        }
    }
}
