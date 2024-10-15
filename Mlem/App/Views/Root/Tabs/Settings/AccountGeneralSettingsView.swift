//
//  AccountGeneralSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI

struct AccountGeneralSettingsView: View {
    @Environment(Palette.self) var palette
    
    @State var showNsfw: Bool = false
    @State var showBotAccounts: Bool = false
    @State var sendNotificationsToEmail: Bool = false
    
    init() {
        guard let session = AppState.main.firstSession as? UserSession else {
            assertionFailure()
            return
        }
        guard let person = session.person else { return }
        _showNsfw = .init(wrappedValue: person.showNsfw)
        _showBotAccounts = .init(wrappedValue: person.showBotAccounts)
        _sendNotificationsToEmail = .init(wrappedValue: person.sendNotificationsToEmail)
    }
    
    var body: some View {
        Form {
            Section {
                Toggle("Show NSFW Content", isOn: $showNsfw)
                    .tint(palette.warning)
                    .onChange(of: showNsfw) {
                        Task {
                            guard let person = (AppState.main.firstSession as? UserSession)?.person else { return }
                            do {
                                try await person.updateSettings(showNsfw: showNsfw)
                            } catch {
                                handleError(error)
                                showNsfw = person.showNsfw
                            }
                        }
                    }
            } footer: {
                Text("Show content flagged as Not Safe For Work.")
            }
            Section {
                Toggle("Show Bot Accounts", isOn: $showBotAccounts)
                    .onChange(of: showBotAccounts) {
                        Task {
                            guard let person = (AppState.main.firstSession as? UserSession)?.person else { return }
                            do {
                                try await person.updateSettings(showBotAccounts: showBotAccounts)
                            } catch {
                                handleError(error)
                                showBotAccounts = person.showBotAccounts
                            }
                        }
                    }
            }
            Section {
                Toggle("Send Notifications to Email", isOn: $sendNotificationsToEmail)
                    .onChange(of: sendNotificationsToEmail) {
                        Task {
                            guard let person = (AppState.main.firstSession as? UserSession)?.person else { return }
                            do {
                                try await person.updateSettings(sendNotificationsToEmail: sendNotificationsToEmail)
                            } catch {
                                handleError(error)
                                sendNotificationsToEmail = person.sendNotificationsToEmail
                            }
                        }
                    }
                    .disabled((AppState.main.firstSession as? UserSession)?.person?.email == nil)
            } footer: {
                if let email = (AppState.main.firstSession as? UserSession)?.person?.email {
                    Text("Notifications will be sent to \(email).")
                } else {
                    Text("You don't have an email attached to this account.")
                }
            }
        }
        .navigationTitle("Content & Notifications")
    }
}
