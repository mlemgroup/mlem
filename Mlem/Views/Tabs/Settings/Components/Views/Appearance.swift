//
//  Appearance.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct AppearanceSettingsView: View {
    
    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified
    
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true
    
    @AppStorage("shouldShowCompactPosts") var shouldShowCompactPosts: Bool = false
    @AppStorage("shouldShowWebsiteFavicons") var shouldShowWebsiteFavicons: Bool = true
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = false
    
    @AppStorage("voteComplexStyle") var voteComplexStyle: VoteComplexStyle = .standard
    
    var body: some View {
        List
        {
            Section("Theme") {
                Picker("Light or dark mode", selection: $lightOrDarkMode) {
                    Image(systemName: "circle")
                        .tag(UIUserInterfaceStyle.light)
                    Image(systemName: "circle.righthalf.filled")
                        .tag(UIUserInterfaceStyle.unspecified)
                    Image(systemName: "circle.fill")
                        .tag(UIUserInterfaceStyle.dark)
                }
                .pickerStyle(.segmented)
            }
            Section("Website Previews")
            {
                WebsiteIconComplex(post:
                                    APIPost(
                                        id: 0,
                                        name: "",
                                        url: URL(string: "https://lemmy.ml/post/1011734")!,
                                        body: "",
                                        creatorId: 0,
                                        communityId: 0,
                                        deleted: false,
                                        embedDescription: nil,
                                        embedTitle: "I am an example of a website preview.\nCustomize me!",
                                        embedVideoUrl: nil,
                                        featuredCommunity: false,
                                        featuredLocal: false,
                                        languageId: 0,
                                        apId: "https://lemmy.ml/post/1011068",
                                        local: true,
                                        locked: false,
                                        nsfw: false,
                                        published: .now,
                                        removed: false,
                                        thumbnailUrl: URL(string: "https://lemmy.ml/pictrs/image/1b759945-6651-497c-bee0-9bdb68f4a829.png"),
                                        updated: nil
                                    )
                                   )
                
                .padding(.horizontal)
                
                SwitchableSettingsItem(
                    settingPictureSystemName: "photo.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show website image",
                    isTicked: $shouldShowWebsitePreviews
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: "globe",
                    settingPictureColor: .pink,
                    settingName: "Show website icons",
                    isTicked: $shouldShowWebsiteFaviconAtAll
                )
                .onChange(of: shouldShowWebsiteFaviconAtAll) { newValue in
                    if shouldShowWebsiteFaviconAtAll == false
                    {
                        shouldShowWebsiteFavicons = false
                    }
                    else
                    {
                        shouldShowWebsiteFavicons = true
                    }
                }
                SwitchableSettingsItem(
                    settingPictureSystemName: "network",
                    settingPictureColor: .pink,
                    settingName: "Show website address",
                    isTicked: $shouldShowWebsiteHost
                )
            }
            Section("Posts")
            {
                SwitchableSettingsItem(
                    settingPictureSystemName: "wifi.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show dynamic website icons",
                    isTicked: $shouldShowWebsiteFavicons
                )
                .disabled(!shouldShowWebsiteFaviconAtAll)
                
                SwitchableSettingsItem(settingPictureSystemName: "rectangle.compress.vertical",
                             settingPictureColor: .pink,
                             settingName: "Compact post view",
                             isTicked: $shouldShowCompactPosts)
            }
            
            Section("Communities")
            {
                SwitchableSettingsItem(
                    settingPictureSystemName: "rectangle.grid.1x2",
                    settingPictureColor: .pink,
                    settingName: "Show community headers",
                    isTicked: $shouldShowCommunityHeaders
                )
            }
            
            Section("Icons")
            {
                SwitchableSettingsItem(
                    settingPictureSystemName: "person.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show user avatars",
                    isTicked: $shouldShowUserAvatars
                )
                
                SwitchableSettingsItem(
                    settingPictureSystemName: "person.2.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show community icons",
                    isTicked: $shouldShowCommunityIcons
                )
            }
            
            Section("Customization") {
                Picker("Vote complex style", selection: $voteComplexStyle) {
                    ForEach(VoteComplexStyle.allCases) { style in
                        Text(style.rawValue.capitalized)
                    }
                }

            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}
