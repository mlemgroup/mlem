//
//  TabBarSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 19/07/2023.
//

import Dependencies
import SwiftUI

struct TabBarSettingsView: View {
    @AppStorage("profileTabLabel") var profileTabLabel: ProfileTabLabel = .username
    @AppStorage("showTabNames") var showTabNames: Bool = true
    @AppStorage("showInboxUnreadBadge") var showInboxUnreadBadge: Bool = true
        
    @EnvironmentObject var appState: AppState
    
    @State var textFieldEntry: String = ""
    
    var body: some View {
        Form {
            // TODO: options like this will need to be updated to only show when there is an active account
            // present once guest mode is fully implemented
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: "person.text.rectangle",
                    settingName: "Profile Tab Label",
                    currentValue: $profileTabLabel,
                    options: ProfileTabLabel.allCases
                )
                
                if profileTabLabel == .nickname {
                    Label {
                        TextField(text: $textFieldEntry, prompt: Text(appState.currentActiveAccount?.nickname ?? "")) {
                            Text("Nickname")
                        }
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            print(textFieldEntry)
                            guard let existingAccount = appState.currentActiveAccount else {
                                return
                            }
                            
                            // disallow blank nicknames
                            let acceptedNickname = textFieldEntry.trimmed.isEmpty ? existingAccount.username : textFieldEntry
                            
                            let newAccount = SavedAccount(
                                from: existingAccount,
                                storedNickname: acceptedNickname,
                                avatarUrl: existingAccount.avatarUrl
                            )
                            appState.setActiveAccount(newAccount)
                        }
                    } icon: {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            .foregroundColor(.pink)
                    }
                }
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: "tag",
                    settingName: "Show Tab Labels",
                    isTicked: $showTabNames
                )
                
                SwitchableSettingsItem(
                    settingPictureSystemName: "envelope.badge",
                    settingName: "Show Unread Count",
                    isTicked: $showInboxUnreadBadge
                )
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Tab Bar")
        .navigationBarColor()
        .animation(.easeIn, value: profileTabLabel)
        .onChange(of: appState.currentActiveAccount?.nickname) { nickname in
            guard let nickname else { return }
            print("new nickname: \(nickname)")
            textFieldEntry = nickname
        }
    }
}
