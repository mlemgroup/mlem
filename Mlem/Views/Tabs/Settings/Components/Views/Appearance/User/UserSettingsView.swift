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
            Section {
                SwitchableSettingsItem(
                    settingPictureSystemName: "person.circle.fill",
                    settingName: "Show User Avatars",
                    isTicked: $shouldShowUserAvatars
                )

                SwitchableSettingsItem(
                    settingPictureSystemName: "rectangle.grid.1x2",
                    settingName: "Show User Banners",
                    isTicked: $shouldShowUserHeaders
                )
            }
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Users")
        .navigationBarColor()
        .hoistNavigation(dismiss: dismiss)
    }
}
