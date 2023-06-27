//
//  Appearance.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct AppearanceSettingsView: View {
    
    // appearance
    @AppStorage("lightOrDarkMode") var lightOrDarkMode: UIUserInterfaceStyle = .unspecified
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("showUsernameInNavigationBar") var showUsernameInNavigationBar: Bool = true
    
    // website previews
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true
    @AppStorage("shouldShowWebsiteFavicons") var shouldShowWebsiteFavicons: Bool = true
    
    // posts
    @AppStorage("shouldShowCompactPosts") var shouldShowCompactPosts: Bool = false
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = false
    
    // comments
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    
    // communities
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = true
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
    
    // icons
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    // other
    @AppStorage("voteComplexStyle") var voteComplexStyle: VoteComplexStyle = .standard
    
    var body: some View {
        List
        {
            Section("Theme") {
                SelectableSettingsItem(
                    settingIconSystemName: "paintbrush",
                    settingName: "App theme",
                    currentValue: $lightOrDarkMode,
                    options: UIUserInterfaceStyle.allCases
                )
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
                
                SwitchableSettingsItem(settingPictureSystemName: "eye.trianglebadge.exclamationmark",
                             settingPictureColor: .pink,
                             settingName: "Blur NSFW",
                             isTicked: $shouldBlurNsfw)
                
                SwitchableSettingsItem(settingPictureSystemName: "server.rack",
                             settingPictureColor: .pink,
                             settingName: "Show user server instance",
                             isTicked: $shouldShowUserServerInPost)
            }
            
            Section("Comments")
            {
                SwitchableSettingsItem(settingPictureSystemName: "server.rack",
                             settingPictureColor: .pink,
                             settingName: "Show user server instance",
                             isTicked: $shouldShowUserServerInComment)
            }
            
            Section("Communities")
            {
                SwitchableSettingsItem(
                    settingPictureSystemName: "person.2.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show community icons",
                    isTicked: $shouldShowCommunityIcons
                )
                
                SwitchableSettingsItem(
                    settingPictureSystemName: "rectangle.grid.1x2",
                    settingPictureColor: .pink,
                    settingName: "Show community banners",
                    isTicked: $shouldShowCommunityHeaders
                )
            }
            
            Section("Users")
            {
                SwitchableSettingsItem(
                    settingPictureSystemName: "person.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show user avatars",
                    isTicked: $shouldShowUserAvatars
                )
                
                SwitchableSettingsItem(
                    settingPictureSystemName: "rectangle.grid.1x2",
                    settingPictureColor: .pink,
                    settingName: "Show user banners",
                    isTicked: $shouldShowUserHeaders
                )
            }
            
            Section("Further customization") {
                SelectableSettingsItem(
                    settingIconSystemName: "arrow.up.arrow.down.square.fill",
                    settingName: "Vote complex style",
                    currentValue: $voteComplexStyle,
                    options: VoteComplexStyle.allCases
                )

            }
            
            Section("Privacy") {
                SwitchableSettingsItem(settingPictureSystemName: "person.fill",
                                       settingPictureColor: .pink,
                                       settingName: "Show Username In Navigation Bar",
                                       isTicked: $showUsernameInNavigationBar)
                
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}
