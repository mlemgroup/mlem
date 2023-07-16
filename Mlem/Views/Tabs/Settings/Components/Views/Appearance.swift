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
    
    // display sides
    @AppStorage("voteComplexOnRight") var shouldShowVoteComplexOnRight: Bool = false
    @AppStorage("thumbnailsOnRight") var shouldShowThumbnailsOnRight: Bool = false
    
    // posts
    @AppStorage("postSize") var postSize: PostSize = PostSize.headline
    @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails: Bool = true
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = true
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = true
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    
    // comments
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    
    // communities
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = true
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
    
    // icons
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    var body: some View {
        VStack {
            List {
                Section("Theme") {
                    SelectableSettingsItem(
                        settingIconSystemName: "paintbrush",
                        settingName: "App theme",
                        currentValue: $lightOrDarkMode,
                        options: UIUserInterfaceStyle.allCases
                    )
                }
                
                Section("Display Sides") {
                    SwitchableSettingsItem(settingPictureSystemName: "arrow.up.arrow.down",
                                           settingPictureColor: .pink,
                                           settingName: "Show vote buttons on right",
                                           isTicked: $shouldShowVoteComplexOnRight)
                    
                    SwitchableSettingsItem(settingPictureSystemName: "photo",
                                           settingPictureColor: .pink,
                                           settingName: "Show thumbnails on right",
                                           isTicked: $shouldShowThumbnailsOnRight)
                }
                
                Section("Posts") {
                    NavigationLink {
                        CustomizePostView()
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "rectangle.and.text.magnifyingglass")
                                .foregroundColor(.pink)
                            Text("Customize Post Display")
                        }
                    }
                    
                    SelectableSettingsItem(
                        settingIconSystemName: "rectangle.compress.vertical",
                        settingName: "Post size",
                        currentValue: $postSize,
                        options: PostSize.allCases
                    )
                    
                    SwitchableSettingsItem(settingPictureSystemName: "eye.trianglebadge.exclamationmark",
                                           settingPictureColor: .pink,
                                           settingName: "Blur NSFW",
                                           isTicked: $shouldBlurNsfw)
                }
                
                Section("Comments") {
                    NavigationLink {
                        CustomizeCommentView()
                    } label: {
                        HStack(alignment: .center) {
                            Image(systemName: "rectangle.and.text.magnifyingglass")
                                .foregroundColor(.pink)
                            Text("Customize Comment Display")
                        }
                    }
                    
                    SwitchableSettingsItem(settingPictureSystemName: "server.rack",
                                           settingPictureColor: .pink,
                                           settingName: "Show user server instance",
                                           isTicked: $shouldShowUserServerInComment)
                }
                
                Section("Communities") {
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
                
                Section("Users") {
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
                
                Section("Privacy") {
                    SwitchableSettingsItem(settingPictureSystemName: "person.fill",
                                           settingPictureColor: .pink,
                                           settingName: "Show Username In Navigation Bar",
                                           isTicked: $showUsernameInNavigationBar)
                    
                }
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}
