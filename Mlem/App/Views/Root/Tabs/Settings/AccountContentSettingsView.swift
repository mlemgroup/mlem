//
//  AccountGeneralSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI

struct AccountContentSettingsView: View {
    @Environment(AppState.self) var appState
    
    @State var showNsfw: Bool = false
    @State var showBotAccounts: Bool = false
    @State var sendNotificationsToEmail: Bool = false
    
    init() {
        guard let person = AppState.main.firstPerson else { return }
        _showNsfw = .init(wrappedValue: person.showNsfw)
        _showBotAccounts = .init(wrappedValue: person.showBotAccounts)
        _sendNotificationsToEmail = .init(wrappedValue: person.sendNotificationsToEmail)
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("Show NSFW Content", systemImage: Icons.blurNsfw, isOn: $showNsfw)
                    .tint(.themedWarning)
                    .onChange(of: showNsfw) {
                        Task {
                            do {
                                try await appState.firstPerson?.updateSettings(showNsfw: showNsfw)
                            } catch {
                                handleError(error)
                                showNsfw = appState.firstPerson?.showNsfw ?? false
                            }
                        }
                    }
            } footer: {
                Text("Show content flagged as Not Safe For Work.")
            }
            Section {
                Toggle("Show Bot Accounts", systemImage: Icons.botFlair, isOn: $showBotAccounts)
                    .onChange(of: showBotAccounts) {
                        Task {
                            do {
                                try await appState.firstPerson?.updateSettings(showBotAccounts: showBotAccounts)
                            } catch {
                                handleError(error)
                                showBotAccounts = appState.firstPerson?.showBotAccounts ?? false
                            }
                        }
                    }
            }
            Section {
                Toggle("Send Notifications to Email", systemImage: Icons.email, isOn: $sendNotificationsToEmail)
                    .onChange(of: sendNotificationsToEmail) {
                        Task {
                            do {
                                try await appState.firstPerson?.updateSettings(sendNotificationsToEmail: sendNotificationsToEmail)
                            } catch {
                                handleError(error)
                                sendNotificationsToEmail = appState.firstPerson?.sendNotificationsToEmail ?? false
                            }
                        }
                    }
                    .disabled(appState.firstPerson?.email == nil)
            } footer: {
                if let email = appState.firstPerson?.email {
                    Text("Notifications will be sent to \(email).")
                } else {
                    Text("You don't have an email attached to this account.")
                }
            }
            
            Section {
                NavigationLink(
                    "Discussion Languages",
                    systemImage: Icons.language,
                    destination: .settings(.accountLanguages)
                )
            }
        }
        .labelStyle(.conditional)
        .navigationTitle("Content & Notifications")
    }
}
