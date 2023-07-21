//
//  CommunitySettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 16/07/2023.
//

import SwiftUI

struct CommunitySettingsView: View {
    
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    var body: some View {
        Form {
            SwitchableSettingsItem(
                settingPictureSystemName: "person.2.circle.fill",
                settingPictureColor: .pink,
                settingName: "Show community avatars",
                isTicked: $shouldShowCommunityIcons
            )

            SwitchableSettingsItem(
                settingPictureSystemName: "rectangle.grid.1x2",
                settingPictureColor: .pink,
                settingName: "Show community banners",
                isTicked: $shouldShowCommunityHeaders
            )
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Communities")
    }
}
