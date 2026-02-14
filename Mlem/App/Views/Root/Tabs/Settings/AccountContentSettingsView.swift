//
//  AccountGeneralSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 13/10/2024.
//

import SwiftUI
import MlemMiddleware

struct AccountContentSettingsView: View {
    @Environment(AppState.self) var appState
    
    @State var showNsfw: Bool = false
    @State var showBotAccounts: Bool = false
    @State var sendNotificationsToEmail: Bool = false
    
    init() {
        guard let person = AppState.main.firstPerson else { return }
        _showNsfw = .init(wrappedValue: person.showNsfw.value_ ?? false)
        _showBotAccounts = .init(wrappedValue: person.showBotAccounts.value_ ?? false)
        _sendNotificationsToEmail = .init(wrappedValue: person.sendNotificationsToEmail.value_ ?? false)
    }
    
    var body: some View {
        if let updateSettings = appState.firstPerson?.updateSettings {
            content(updateSettings: updateSettings)
        } else {
            ProgressView()
        }
    }
    
    // swiftlint:disable:next function_body_length
    func content(updateSettings: @escaping (Person.ProfileSettings) async throws -> Void) -> some View {
        Form {
            Section {
                Toggle("Show NSFW Content", icon: .settings.blurNsfw, isOn: $showNsfw)
                    .tint(.themedWarning)
                    .onChange(of: showNsfw) {
                        Task {
                            do {
                                try await updateSettings(.init(showNsfw: showNsfw))
                            } catch {
                                handleError(error)
                                showNsfw = appState.firstPerson?.showNsfw.value_ ?? false
                            }
                        }
                    }
            } footer: {
                Text("Show content flagged as Not Safe For Work.")
            }
            Section {
                Toggle("Show Bot Accounts", icon: .lemmy.botFlair, isOn: $showBotAccounts)
                    .onChange(of: showBotAccounts) {
                        Task {
                            do {
                                try await updateSettings(.init(showBotAccounts: showBotAccounts))
                            } catch {
                                handleError(error)
                                showBotAccounts = appState.firstPerson?.showBotAccounts.value_ ?? false
                            }
                        }
                    }
            }
            Section {
                Toggle("Send Notifications to Email", icon: .general.email, isOn: $sendNotificationsToEmail)
                    .onChange(of: sendNotificationsToEmail) {
                        Task {
                            do {
                                try await updateSettings(.init(sendNotificationsToEmail: sendNotificationsToEmail))
                            } catch {
                                handleError(error)
                                sendNotificationsToEmail = appState.firstPerson?.sendNotificationsToEmail.value_ ?? false
                            }
                        }
                    }
                    .disabled(appState.firstPerson?.email == nil)
            } footer: {
                if let email = appState.firstPerson?.email.value as? String {
                    Text("Notifications will be sent to \(email).")
                } else {
                    Text("You don't have an email attached to this account.")
                }
            }
            
            Section {
                NavigationLink(
                    "Discussion Languages",
                    icon: .settings.language,
                    destination: .settings(.accountLanguages)
                )
            }
        }
        .withConditionalLabelStyle()
        .navigationTitle("Content & Notifications")
    }
}
