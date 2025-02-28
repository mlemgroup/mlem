//
//  AccountSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 09/05/2024.
//

import SwiftUI

struct AccountSettingsView: View {
    @Environment(Palette.self) var palette
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
                .foregroundStyle(palette.primary) // override default .secondary style
            }
            .textCase(nil) // override default all-caps
            .listRowInsets(.init(top: 10, leading: 0, bottom: 0, trailing: 0))
            
            if appState.firstSession is UserSession {
                Section {
                    NavigationLink(
                        "My Profile",
                        systemImage: Icons.personFill,
                        destination: .settings(.profile)
                    )
                    .tint(palette.colorfulAccent(5))
                    NavigationLink(
                        "Sign-In & Security",
                        systemImage: Icons.securityFill,
                        destination: .settings(.accountSignIn)
                    )
                    .tint(palette.colorfulAccent(2))
                    NavigationLink(
                        "Content & Notifications",
                        systemImage: "list.bullet.rectangle.fill",
                        destination: .settings(.accountContent)
                    )
                    .tint(palette.colorfulAccent(0))
                    NavigationLink(
                        "Advanced",
                        systemImage: "gearshape.2.fill",
                        destination: .settings(.accountAdvanced)
                    )
                    .tint(palette.neutralAccent)
                }
                Section {
                    NavigationLink(
                        "Block List",
                        systemImage: Icons.blockFill,
                        destination: .blockList
                    )
                    .tint(palette.negative)
                }
                Section {
                    NavigationLink(
                        "Local Options",
                        systemImage: "iphone",
                        destination: .settings(.accountLocal)
                    )
                    .tint(palette.colorfulAccent(2))
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
                        Text(signOutLabel.localized())
                            .frame(maxWidth: .infinity)
                    }
                    .confirmationDialog(signOutPrompt, isPresented: $showingSignOutConfirmation) {
                        Button(signOutLabel.localized(), role: .destructive) {
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
            .tint(palette.warning)
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
    
    var signOutLabel: String {
        appState.firstAccount is UserAccount ? "Sign Out" : "Remove"
    }
    
    var signOutPrompt: String {
        if appState.firstAccount is UserAccount {
            "Really sign out of \(appState.firstAccount.nickname)?"
        } else {
            "Really remove \(appState.firstAccount.nickname)?"
        }
    }
}
