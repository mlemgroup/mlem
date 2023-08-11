//
//  TabBarSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 19/07/2023.
//

import SwiftUI

struct TabBarSettingsView: View {
    @AppStorage("profileTabLabel") var profileTabLabel: ProfileTabLabel = .username
    @AppStorage("showTabNames") var showTabNames: Bool = true
    @AppStorage("showInboxUnreadBadge") var showInboxUnreadBadge: Bool = true
    @AppStorage("showSolidBarColor") var showSolidBarColor: Bool = false
        
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var savedAccountTracker: SavedAccountTracker
    
    @State var textFieldEntry: String = ""
    
    var body: some View {
        Form {
            Section {
                SelectableSettingsItem(settingIconSystemName: "person.text.rectangle",
                                       settingName: "Profile Tab Label",
                                       currentValue: $profileTabLabel,
                                       options: ProfileTabLabel.allCases)
                
                if profileTabLabel == .nickname {
                    Label {
                        TextField(text: $textFieldEntry, prompt: Text(appState.currentNickname)) {
                            Text("Nickname")
                        }
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .onSubmit {
                            print(textFieldEntry)
                            let newAccount = SavedAccount(from: appState.currentActiveAccount, storedNickname: textFieldEntry)
                            appState.changeDisplayedNickname(to: textFieldEntry)
                            savedAccountTracker.replaceAccount(account: newAccount)
                        }
                    } icon: {
                        Image(systemName: "rectangle.and.pencil.and.ellipsis")
                            .foregroundColor(.pink)
                    }
                }
            }
            
            Section {
                SwitchableSettingsItem(settingPictureSystemName: "tag",
                                       settingName: "Show Tab Labels",
                                       isTicked: $showTabNames)
                
                SwitchableSettingsItem(settingPictureSystemName: "envelope.badge",
                                       settingName: "Show Unread Count",
                                       isTicked: $showInboxUnreadBadge)
            }
            
            Section {
                SwitchableSettingsItem(settingPictureSystemName: "paintpalette",
                                       settingName: "Solid Color",
                                       isTicked: $showSolidBarColor)
            }
        }
        .fancyTabScrollCompatible()
        .animation(.easeIn, value: profileTabLabel)
        .onChange(of: appState.currentActiveAccount.nickname) { nickname in
            print("new nickname: \(nickname)")
            textFieldEntry = nickname // appState.currentActiveAccount.nickname
        }
    }
}
