//
//  TabBarSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 19/07/2023.
//

import Dependencies
import SwiftUI

struct TabBarSettingsView: View {
    @AppStorage("profileTabLabel") var profileTabLabel: ProfileTabLabel = .nickname
    @AppStorage("showTabNames") var showTabNames: Bool = true
    @AppStorage("showInboxUnreadBadge") var showInboxUnreadBadge: Bool = true
    @AppStorage("showUserAvatarOnProfileTab") var showUserAvatar: Bool = true
    @AppStorage("homeButtonExists") var homeButtonExists: Bool = false
    
    var body: some View {
        Form {
            // TODO: options like this will need to be updated to only show when there is an active account
            // present once guest mode is fully implemented
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: Icons.profileTabSettings,
                    settingName: "Profile Tab Label",
                    currentValue: $profileTabLabel,
                    options: ProfileTabLabel.allCases
                )
            }
            
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.label,
                    settingName: "Show Tab Labels",
                    isTicked: $showTabNames
                )
                
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.unreadBadge,
                    settingName: "Show Unread Count",
                    isTicked: $showInboxUnreadBadge
                )
                
                SwitchableSettingsItem(
                    settingPictureSystemName: Icons.showAvatar,
                    settingName: "Show User Avatar",
                    // if `.anonymous` is selected the toggle here should always be false
                    isTicked: profileTabLabel == .anonymous ? .constant(false) : $showUserAvatar
                )
                .disabled(profileTabLabel == .anonymous)
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Tab Bar")
        .navigationBarColor()
        .animation(.easeIn, value: profileTabLabel)
    }
}
