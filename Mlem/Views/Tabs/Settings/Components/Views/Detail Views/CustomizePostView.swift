//
//  CustomizePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-08.
//

import Foundation
import SwiftUI

struct CustomizePostView: View {
    @EnvironmentObject var appState: AppState
    
    @AppStorage("postSize") var postSize: PostSize = PostSize.headline
    @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails: Bool = false
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = false
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = false
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    
    // website previews
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true
    @AppStorage("shouldShowWebsiteFavicons") var shouldShowWebsiteFavicons: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section("Layout") {
                    SelectableSettingsItem(
                        settingIconSystemName: "rectangle.compress.vertical",
                        settingName: "Post size",
                        currentValue: $postSize,
                        options: PostSize.allCases
                    )
                    
                    SwitchableSettingsItem(settingPictureSystemName: "server.rack",
                                           settingPictureColor: .pink,
                                           settingName: "Show user server instance",
                                           isTicked: $shouldShowUserServerInPost)
                    
                    SwitchableSettingsItem(settingPictureSystemName: "server.rack",
                                           settingPictureColor: .pink,
                                           settingName: "Show community server instance",
                                           isTicked: $shouldShowCommunityServerInPost)
                    
                    SwitchableSettingsItem(settingPictureSystemName: "signature",
                                           settingPictureColor: .pink,
                                           settingName: "Show post creator",
                                           isTicked: $shouldShowPostCreator)
                    
                    SwitchableSettingsItem(settingPictureSystemName: "photo",
                                           settingPictureColor: .pink,
                                           settingName: "Show post thumbnails",
                                           isTicked: $shouldShowPostThumbnails)
                }
                
                Section("Website Previews") {
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
                    .onChange(of: shouldShowWebsiteFaviconAtAll) { _ in
                        if shouldShowWebsiteFaviconAtAll == false {
                            shouldShowWebsiteFavicons = false
                        } else {
                            shouldShowWebsiteFavicons = true
                        }
                    }
                    SwitchableSettingsItem(
                        settingPictureSystemName: "network",
                        settingPictureColor: .pink,
                        settingName: "Show website address",
                        isTicked: $shouldShowWebsiteHost
                    )
                    
                    SwitchableSettingsItem(
                        settingPictureSystemName: "wifi.circle.fill",
                        settingPictureColor: .pink,
                        settingName: "Show dynamic website icons",
                        isTicked: $shouldShowWebsiteFavicons
                    )
                    .disabled(!shouldShowWebsiteFaviconAtAll)
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .navigationTitle("Customize Post Display")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
