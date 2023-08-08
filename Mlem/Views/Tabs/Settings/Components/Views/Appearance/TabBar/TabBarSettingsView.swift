//
//  TabBarSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 19/07/2023.
//

import SwiftUI

struct TabBarSettingsView: View {
    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true
    @AppStorage("showTabNames") var showTabNames: Bool = true
    @AppStorage("showInboxUnreadBadge") var showInboxUnreadBadge: Bool = true
        
    var body: some View {
        Form {
            SwitchableSettingsItem(settingPictureSystemName: "tag",
                                   settingPictureColor: .pink,
                                   settingName: "Show tab labels",
                                   isTicked: $showTabNames)
            
            Section {
                SwitchableSettingsItem(settingPictureSystemName: "person.text.rectangle",
                                       settingPictureColor: .pink,
                                       settingName: "Show username",
                                       isTicked: $showUsernameInNavigationBar)
            } footer: {
                // swiftlint:disable line_length
                Text("When enabled, your username will be displayed as the label for the Profile tab. You may wish to turn this off for privacy reasons.")
                // swiftlint:enable line_length
            }
            
            SwitchableSettingsItem(settingPictureSystemName: "envelope.badge",
                                   settingPictureColor: .pink,
                                   settingName: "Show unread count",
                                   isTicked: $showInboxUnreadBadge)
        }
        .fancyTabScrollCompatible()
    }
}
