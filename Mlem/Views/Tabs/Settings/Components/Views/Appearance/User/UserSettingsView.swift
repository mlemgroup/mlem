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
                settingPictureSystemName: AppConstants.userSymbolName,
                settingName: "Show Avatars",
                isTicked: $shouldShowUserAvatars
            )
            SwitchableSettingsItem(
                settingPictureSystemName: AppConstants.bannerSymbolName,
                settingName: "Show Banners",
                isTicked: $shouldShowUserHeaders
            )
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Users")
        .navigationBarColor()
        .hoistNavigation(dismiss: dismiss)
    }
}
