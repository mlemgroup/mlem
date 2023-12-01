//
//  AccountNotificationsSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 01/12/2023.
//

import SwiftUI
import Dependencies

struct AccountNotificationsSettingsView: View {
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    @Dependency(\.apiClient) var apiClient: APIClient
    @Dependency(\.errorHandler) var errorHandler: ErrorHandler
    
    @State var showNewPostNotifs: Bool = false
    @State var sendNotificationsToEmail: Bool = false
    
    init() {
        if let user = siteInformation.myUserInfo?.localUserView.localUser {
            _showNewPostNotifs = State(wrappedValue: user.showNewPostNotifs ?? false)
            _sendNotificationsToEmail = State(wrappedValue: user.sendNotificationsToEmail)
        }
    }
    
    var body: some View {
        Form {
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: "doc.plaintext",
                    settingName: "Notify for New Posts",
                    isTicked: $showNewPostNotifs
                )
                .onChange(of: showNewPostNotifs) { newValue in
                    if newValue != siteInformation.myUserInfo?.localUserView.localUser.showNewPostNotifs {
                        siteInformation.myUserInfo?.localUserView.localUser.showNewPostNotifs = newValue
                        Task {
                            if let info = siteInformation.myUserInfo {
                                do {
                                    try await apiClient.saveUserSettings(myUserInfo: info)
                                } catch {
                                    showNewPostNotifs = !newValue
                                    siteInformation.myUserInfo?.localUserView.localUser.showNewPostNotifs = showNewPostNotifs
                                    errorHandler.handle(error)
                                }
                            }
                        }
                    }
                }
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
            } footer: {
                if let email = siteInformation.myUserInfo?.localUserView.localUser.email {
                    Text("Notifications will be sent to \(email).")
                }
            }
        }
        .navigationTitle("Notifications")
    }
}
