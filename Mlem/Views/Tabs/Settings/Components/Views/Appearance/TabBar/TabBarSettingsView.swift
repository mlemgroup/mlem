//
//  TabBarSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 19/07/2023.
//

import SwiftUI

struct TabBarSettingsView: View {
    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true
    @AppStorage("profileTabLabel") var profileTabLabel: ProfileTabLabel = .username
    @AppStorage("showTabNames") var showTabNames: Bool = true
    @AppStorage("showInboxUnreadBadge") var showInboxUnreadBadge: Bool = true
        
    @EnvironmentObject var appState: AppState
    
    @State var textFieldEntry: String = ""
    
    var body: some View {
        Form {
            SwitchableSettingsItem(settingPictureSystemName: "tag",
                                   settingName: "Show Tab Labels",
                                   isTicked: $showTabNames)
            
//            Section {
//                SwitchableSettingsItem(settingPictureSystemName: "person.text.rectangle",
//                                       settingName: "Show Username",
//                                       isTicked: $showUsernameInNavigationBar)
//            } footer: {
//                Text("Displays your username as the label for the \"Profile\" tab.")
//            }
            
            SwitchableSettingsItem(settingPictureSystemName: "envelope.badge",
                                   settingName: "Show Unread Count",
                                   isTicked: $showInboxUnreadBadge)
            
            VStack {
                SelectableSettingsItem(settingIconSystemName: "person.text.rectangle",
                                       settingName: "Profile Tab Label",
                                       currentValue: $profileTabLabel,
                                       options: ProfileTabLabel.allCases)
                
                TextField(text: $textFieldEntry, prompt: Text(appState.currentActiveAccount.username)) {
                    Text("Nickname")
                }
                .onSubmit {
                    appState.setNickname(nickname: textFieldEntry)
                }
            }
        }
        .fancyTabScrollCompatible()
        .onChange(of: appState.currentActiveAccount.nickname) { _ in
            textFieldEntry = appState.currentActiveAccount.nickname
        }
    }
}
