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
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
    @AppStorage("postSize") var postSize: PostSize = PostSize.headline
    
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
    
    @State private var showingWidgetSheet = false

    var body: some View {
        Form {
            Section {
                SelectableSettingsItem(
                    settingIconSystemName: "rectangle.compress.vertical",
                    settingName: "Post Size",
                    currentValue: $postSize,
                    options: PostSize.allCases
                )
            
                Button {
                    showingWidgetSheet = true
                } label: {
                    HStack {
                        Text("Customize widgets")
                        Spacer()
                        Image(systemName: "arrow.up.square.fill")
                        Image(systemName: "arrow.down.square")
                    }
                    .foregroundStyle(.pink)
                }
            } footer: {
                Text("Post widgets are visible in Large or Headline mode.")
            }
            
            Section("Body") {

                SwitchableSettingsItem(settingPictureSystemName: "photo",
                                       settingName: "Thumbnails On Right",
                                       isTicked: $shouldShowThumbnailsOnRight)
                SwitchableSettingsItem(settingPictureSystemName: "server.rack",
                                       settingName: "Show User Server Instance",
                                       isTicked: $shouldShowUserServerInPost)
                
                SwitchableSettingsItem(settingPictureSystemName: "server.rack",
                                       settingName: "Show Community Server Instance",
                                       isTicked: $shouldShowCommunityServerInPost)
                
                SwitchableSettingsItem(settingPictureSystemName: "signature",
                                       settingName: "Show Post Creator",
                                       isTicked: $shouldShowPostCreator)
                
                SwitchableSettingsItem(settingPictureSystemName: "photo",
                                       settingName: "Show Post Thumbnails",
                                       isTicked: $shouldShowPostThumbnails)
            }
            
            Section("Interactions and Info") {

                SwitchableSettingsItem(settingPictureSystemName: AppConstants.emptyUpvoteSymbolName,
                                       settingName: "Show Score In Info",
                                       isTicked: $shouldShowScoreInPostBar)
                SwitchableSettingsItem(settingPictureSystemName: AppConstants.generalVoteSymbolName,
                                       settingName: "Show Downvotes Separately",
                                       isTicked: $showDownvotesSeparately)
                SwitchableSettingsItem(settingPictureSystemName: "clock",
                                       settingName: "Show Time Posted In Info",
                                       isTicked: $shouldShowTimeInPostBar)
                SwitchableSettingsItem(settingPictureSystemName: "bookmark",
                                       settingName: "Show Saved Status In Info",
                                       isTicked: $shouldShowSavedInPostBar)
                SwitchableSettingsItem(settingPictureSystemName: "bubble.right",
                                       settingName: "Show Replies In Info",
                                       isTicked: $shouldShowRepliesInPostBar)
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
                    settingName: "Show Website Address",
                    isTicked: $shouldShowWebsiteHost
                )
                SwitchableSettingsItem(
                    settingPictureSystemName: "globe",
                    settingName: "Show Website Icon",
                    isTicked: $shouldShowWebsiteIcon
                )
                .disabled(!shouldShowWebsiteHost)
                SwitchableSettingsItem(
                    settingPictureSystemName: "photo.circle.fill",
                    settingName: "Show Website Preview",
                    isTicked: $shouldShowWebsitePreviews
                )
            }

        }
        
        .fancyTabScrollCompatible()
        .navigationTitle("Posts")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingWidgetSheet) {
            PostLayoutEditView($showingWidgetSheet, widgets: layoutWidgetTracker.groups!.post, onSave: { widgets in
                layoutWidgetTracker.groups?.post = widgets
                layoutWidgetTracker.saveToDisk()
            })
                .interactiveDismissDisabled()
        }
    }
}
