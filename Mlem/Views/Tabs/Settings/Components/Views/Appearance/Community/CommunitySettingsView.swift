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
                settingPictureSystemName: Icons.communitySymbolName,
                settingName: "Show Avatars",
                isTicked: $shouldShowCommunityIcons
            )
            SwitchableSettingsItem(
                settingPictureSystemName: Icons.bannerSymbolName,
                settingName: "Show Banners",
                isTicked: $shouldShowCommunityHeaders
            )
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Communities")
    }
}
