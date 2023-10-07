//
//  UserSettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 16/07/2023.
//

import SwiftUI

struct UserSettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
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
                settingPictureSystemName: Icons.banner,
                settingName: "Show Banners",
                isTicked: $shouldShowUserHeaders
            )
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Users")
        .hoistNavigation(dismiss: dismiss)
    }
}
