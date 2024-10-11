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
            .listRowInsets(.init(top: 40, leading: 0, bottom: 0, trailing: 0))
            
            Section {
                Button("Sign Out") {
                    appState.firstAccount.signOut()
                }
            }
            
            if let account = appState.firstAccount as? UserAccount {
                Section {
                    Button("Delete Account", role: .destructive) {
                        navigation.openSheet(.deleteAccount(account))
                    }
                }
            }
        }
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
}
