//
//  CommunitySettingsView.swift
//  Mlem
//
//  Created by Sam Marfleet on 16/07/2023.
//
import SwiftUI
struct CommunitySettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    var body: some View {
        Form {
            SwitchableSettingsItem(
                settingPictureSystemName: AppConstants.communitySymbolName,
                settingName: "Show Avatars",
                isTicked: $shouldShowCommunityIcons
            )
            SwitchableSettingsItem(
                settingPictureSystemName: AppConstants.bannerSymbolName,
                settingName: "Show Banners",
                isTicked: $shouldShowCommunityHeaders
            )
        }
        .fancyTabScrollCompatible()
        .navigationTitle("Communities")
        .hoistNavigation(dismiss: dismiss)
    }
}
