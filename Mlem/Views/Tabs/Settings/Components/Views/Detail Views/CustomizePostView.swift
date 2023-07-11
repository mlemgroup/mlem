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
    
    // body
    @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails: Bool = false
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = false
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = false
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    
    // interactions and info
    @AppStorage("voteComplexStyle") var voteComplexStyle: VoteComplexStyle = .standard
    @AppStorage("voteComplexOnRight") var shouldShowVoteComplexOnRight: Bool = false
    @AppStorage("shouldShowUpvotesInBar") var shouldShowUpvotesInBar: Bool = false
    @AppStorage("shouldShowTimeInBar") var shouldShowTimeInBar: Bool = true
    @AppStorage("shouldShowSavedInBar") var shouldShowSavedInBar: Bool = false
    @AppStorage("shouldShowRepliesInBar") var shouldShowRepliesInBar: Bool = true
    
    // website previews
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true
    @AppStorage("shouldShowWebsiteIcon") var shouldShowWebsiteIcon: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section("Body") {
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
                
                Section("Interactions and Info") {
                    SelectableSettingsItem(
                        settingIconSystemName: "arrow.up.arrow.down.square",
                        settingName: "Vote complex style",
                        currentValue: $voteComplexStyle,
                        options: VoteComplexStyle.allCases
                    )
                    SwitchableSettingsItem(settingPictureSystemName: "arrow.up.arrow.down",
                                           settingPictureColor: .pink,
                                           settingName: "Show vote buttons on right",
                                           isTicked: $shouldShowVoteComplexOnRight)
                    SwitchableSettingsItem(settingPictureSystemName: AppConstants.emptyUpvoteSymbolName,
                                           settingPictureColor: .pink,
                                           settingName: "Show upvotes in info",
                                           isTicked: $shouldShowUpvotesInBar)
                    SwitchableSettingsItem(settingPictureSystemName: "clock",
                                           settingPictureColor: .pink,
                                           settingName: "Show time posted in info",
                                           isTicked: $shouldShowTimeInBar)
                    SwitchableSettingsItem(settingPictureSystemName: "bookmark",
                                           settingPictureColor: .pink,
                                           settingName: "Show saved status in info",
                                           isTicked: $shouldShowSavedInBar)
                    SwitchableSettingsItem(settingPictureSystemName: "bubble.right",
                                           settingPictureColor: .pink,
                                           settingName: "Show replies in info",
                                           isTicked: $shouldShowRepliesInBar)
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
                        settingPictureSystemName: "network",
                        settingPictureColor: .pink,
                        settingName: "Show website address",
                        isTicked: $shouldShowWebsiteHost
                    )
                    SwitchableSettingsItem(
                        settingPictureSystemName: "globe",
                        settingPictureColor: .pink,
                        settingName: "Show website icon",
                        isTicked: $shouldShowWebsiteIcon
                    )
                    .disabled(!shouldShowWebsiteHost)
                    SwitchableSettingsItem(
                        settingPictureSystemName: "photo.circle.fill",
                        settingPictureColor: .pink,
                        settingName: "Show website preview",
                        isTicked: $shouldShowWebsitePreviews
                    )
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
            .navigationTitle("Customize Post Display")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
