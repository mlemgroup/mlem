//
//  CustomizePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-08.
//

import Foundation
import SwiftUI

struct PostSettingsView: View {
    @EnvironmentObject var appState: AppState
    
    @AppStorage("postSize") var postSize: PostSize = PostSize.headline
    @AppStorage("voteComplexOnRight") var shouldShowVoteComplexOnRight: Bool = false
    
    // Thumbnails
    @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails: Bool = true
    @AppStorage("thumbnailsOnRight") var shouldShowThumbnailsOnRight: Bool = false
    
    // Community
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = true
    
    // Author
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = true
    
    // Complications
    @AppStorage("postVoteComplexStyle") var postVoteComplexStyle: VoteComplexStyle = .plain
    @AppStorage("showDownvotesSeparately") var showDownvotesSeparately: Bool = false
    @AppStorage("shouldShowScoreInPostBar") var shouldShowScoreInPostBar: Bool = true
    @AppStorage("shouldShowTimeInPostBar") var shouldShowTimeInPostBar: Bool = true
    @AppStorage("shouldShowSavedInPostBar") var shouldShowSavedInPostBar: Bool = false
    @AppStorage("shouldShowRepliesInPostBar") var shouldShowRepliesInPostBar: Bool = true
    
    // website previews
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true
    @AppStorage("shouldShowWebsiteIcon") var shouldShowWebsiteIcon: Bool = true
    
    var body: some View {
        Form {
            Section("Post Size") {
                SelectableSettingsItem(
                    settingIconSystemName: "rectangle.compress.vertical",
                    settingName: "Post size",
                    currentValue: $postSize,
                    options: PostSize.allCases
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
                    currentValue: $postVoteComplexStyle,
                    options: VoteComplexStyle.allCases
                )
                SwitchableSettingsItem(settingPictureSystemName: AppConstants.emptyUpvoteSymbolName,
                                       settingPictureColor: .pink,
                                       settingName: "Show score in info",
                                       isTicked: $shouldShowScoreInPostBar)
                SwitchableSettingsItem(settingPictureSystemName: AppConstants.generalVoteSymbolName,
                                       settingPictureColor: .pink,
                                       settingName: "Show downvotes separately",
                                       isTicked: $showDownvotesSeparately)
                SwitchableSettingsItem(settingPictureSystemName: "clock",
                                       settingPictureColor: .pink,
                                       settingName: "Show time posted in info",
                                       isTicked: $shouldShowTimeInPostBar)
                SwitchableSettingsItem(settingPictureSystemName: "bookmark",
                                       settingPictureColor: .pink,
                                       settingName: "Show saved status in info",
                                       isTicked: $shouldShowSavedInPostBar)
                SwitchableSettingsItem(settingPictureSystemName: "bubble.right",
                                       settingPictureColor: .pink,
                                       settingName: "Show replies in info",
                                       isTicked: $shouldShowRepliesInPostBar)
            }
            
            Section("Website Previews") {
                WebsiteIconComplex(post: APIPost(
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
        .fancyTabScrollCompatible()
        .navigationTitle("Posts")
        .navigationBarTitleDisplayMode(.inline)
    }
}
