//
//  AccountNotificationsSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 01/12/2023.
//

import SwiftUI
import Dependencies

struct AccountGeneralSettingsView: View {
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    @Dependency(\.apiClient) var apiClient: APIClient
    @Dependency(\.errorHandler) var errorHandler: ErrorHandler
    
    @State var showNsfw: Bool = false
    @State var showBotAccounts: Bool = false
    @State var sendNotificationsToEmail: Bool = false
    
    @State var discussionLanguages: Set<Int> = .init()
    
    init() {
        if let info = siteInformation.myUserInfo {
            _showNsfw = State(wrappedValue: info.localUserView.localUser.showNsfw)
            _showBotAccounts = State(wrappedValue: info.localUserView.localUser.showBotAccounts)
            _sendNotificationsToEmail = State(wrappedValue: info.localUserView.localUser.sendNotificationsToEmail)
            _discussionLanguages = State(wrappedValue: Set(info.discussionLanguages))
        }
        
    }
    
    func saveDiscussionLanguages() {
        let newValue = Array(discussionLanguages).sorted()
        if newValue != siteInformation.myUserInfo?.discussionLanguages {
            let oldValues = siteInformation.myUserInfo?.discussionLanguages ?? []
            siteInformation.myUserInfo?.discussionLanguages = newValue
            Task {
                if let info = siteInformation.myUserInfo {
                    do {
                        try await apiClient.saveUserSettings(myUserInfo: info)
                    } catch {
                        discussionLanguages = Set(oldValues)
                        siteInformation.myUserInfo?.discussionLanguages = oldValues
                        errorHandler.handle(error)
                    }
                }
            }
        }
    }
    
    var body: some View {

        Form {
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.blurNsfw,
                    settingPictureColor: .red,
                    settingName: "Show NSFW Content",
                    isTicked: $showNsfw
                )
                .tint(.red)
                .onChange(of: showNsfw) { newValue in
                    if newValue != siteInformation.myUserInfo?.localUserView.localUser.showNsfw {
                        siteInformation.myUserInfo?.localUserView.localUser.showNsfw = newValue
                        Task {
                            if let info = siteInformation.myUserInfo {
                                do {
                                    try await apiClient.saveUserSettings(myUserInfo: info)
                                } catch {
                                    showNsfw = !newValue
                                    siteInformation.myUserInfo?.localUserView.localUser.showNsfw = showNsfw
                                    errorHandler.handle(error)
                                }
                            }
                        }
                    }
                }
            }
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: "terminal",
                    settingName: "Show Bot Accounts",
                    isTicked: $showBotAccounts
                )
                .onChange(of: showBotAccounts) { newValue in
                    if newValue != siteInformation.myUserInfo?.localUserView.localUser.showBotAccounts {
                        siteInformation.myUserInfo?.localUserView.localUser.showBotAccounts = newValue
                        Task {
                            if let info = siteInformation.myUserInfo {
                                do {
                                    try await apiClient.saveUserSettings(myUserInfo: info)
                                } catch {
                                    showBotAccounts = !newValue
                                    siteInformation.myUserInfo?.localUserView.localUser.showBotAccounts = showBotAccounts
                                    errorHandler.handle(error)
                                }
                            }
                        }
                    }
                }
            }
            Section {
                NavigationLink("Discussion Languages") {
                    Form {
                        Section {
                            Toggle(isOn: Binding(
                                get: { discussionLanguages.contains(0) },
                                set: { selected in
                                    if selected {
                                        discussionLanguages.insert(0)
                                    } else {
                                        discussionLanguages.remove(0)
                                    }
                                    saveDiscussionLanguages()
                                }
                            )) {
                                Text("Undetermined")
                            }
                        }
                        Section {
                            ForEach(siteInformation.allLanguages.dropFirst(), id: \.self) { language in
                                Toggle(isOn: Binding(
                                    get: { discussionLanguages.contains(language.id) },
                                    set: { selected in
                                        if selected {
                                            discussionLanguages.insert(language.id)
                                        } else {
                                            discussionLanguages.remove(language.id)
                                        }
                                        saveDiscussionLanguages()
                                    }
                                )) {
                                    Text(language.name)
                                }
                            }
                        }
                    }
                    .fancyTabScrollCompatible()
                }
                
            } footer: {
                Text("If you deselect Undetermined, you won't see most content.")
            }
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: "envelope",
                    settingName: "Send Notifications to Email",
                    isTicked: $sendNotificationsToEmail
                )
                .onChange(of: sendNotificationsToEmail) { newValue in
                    if newValue != siteInformation.myUserInfo?.localUserView.localUser.sendNotificationsToEmail {
                        siteInformation.myUserInfo?.localUserView.localUser.sendNotificationsToEmail = newValue
                        Task {
                            if let info = siteInformation.myUserInfo {
                                do {
                                    try await apiClient.saveUserSettings(myUserInfo: info)
                                } catch {
                                    sendNotificationsToEmail = !newValue
                                    siteInformation.myUserInfo?.localUserView.localUser.sendNotificationsToEmail = sendNotificationsToEmail
                                    errorHandler.handle(error)
                                }
                            }
                        }
                    }
                }
                .disabled(siteInformation.myUserInfo?.localUserView.localUser.email == nil)
            } footer: {
                if let email = siteInformation.myUserInfo?.localUserView.localUser.email {
                    Text("Notifications will be sent to \(email).")
                } else {
                    Text("You don't have an email attached to this account.")
                }
            }
        }
        .navigationTitle("Content & Notifications")
    }
}
