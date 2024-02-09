//
//  AdvancedAccountSettingsView.swift
//  Mlem
//
//  Created by Sjmarf on 02/12/2023.
//

import Dependencies
import SwiftUI

struct AdvancedAccountSettingsView: View {
    @Dependency(\.siteInformation) var siteInformation: SiteInformationTracker
    @Dependency(\.apiClient) var apiClient: APIClient
    @Dependency(\.errorHandler) var errorHandler: ErrorHandler
    
    @State var botAccount: Bool = false
    
    init() {
        _botAccount = State(wrappedValue: siteInformation.myUserInfo?.localUserView.person.botAccount ?? false)
    }
    
    var body: some View {
        Form {
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: "terminal",
                    settingPictureColor: .indigo,
                    settingName: "Bot Account",
                    isTicked: $botAccount
                )
                .tint(.indigo)
                .onChange(of: botAccount) { newValue in
                    if newValue != siteInformation.myUserInfo?.localUserView.person.botAccount {
                        siteInformation.myUserInfo?.localUserView.person.botAccount = newValue
                        Task {
                            if let info = siteInformation.myUserInfo {
                                do {
                                    try await apiClient.saveUserSettings(myUserInfo: info)
                                } catch {
                                    botAccount = !newValue
                                    siteInformation.myUserInfo?.localUserView.person.botAccount = botAccount
                                    errorHandler.handle(error)
                                }
                            }
                        }
                    }
                }
            } footer: {
                Text("Bot accounts cannot vote on posts.")
            }
        }
        .navigationTitle("Advanced")
        .hoistNavigation()
    }
}
