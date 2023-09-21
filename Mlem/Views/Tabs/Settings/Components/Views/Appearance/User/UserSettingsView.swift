//
//  UserSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 16/07/2023.
//

import SwiftUI

struct UserSettingsView: View {
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    
    var body: some View {
        Form {
            SwitchableSettingsItem(
                settingPictureSystemName: Icons.user,
                settingName: "Show Avatars",
                isTicked: $shouldShowUserAvatars
            )
            SwitchableSettingsItem(
                settingPictureSystemName: Icons.bannerSymbolName,
                settingName: "Show Banners",
                isTicked: $shouldShowUserHeaders
            )
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Users")
    }
}
