//
//  Appearance.swift
//  Mlem
//
//  Created by David Bureš on 08.05.2023.
//

import SwiftUI

struct AppearanceSettingsView: View {
    
    @AppStorage("shouldShowWebsitePreviews") var shouldShowWebsitePreviews: Bool = true
    @AppStorage("shouldShowWebsiteFaviconAtAll") var shouldShowWebsiteFaviconAtAll: Bool = true
    @AppStorage("shouldShowWebsiteHost") var shouldShowWebsiteHost: Bool = true
    
    @AppStorage("shouldShowWebsiteFavicons") var shouldShowWebsiteFavicons: Bool = true
    @AppStorage("postDisplayType") var postDisplayType: PostDisplayOptions = .fullDisplay
    
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = false
    
    var body: some View {
        List
        {
            Section("Website Previews")
            {
                WebsiteIconComplex(post: Post(
                    id: 0, name: "", url: URL(string: "https://lemmy.ml/post/1011734")!, body: "", removed: nil, locked: nil, published: Date(), updated: nil, deleted: false, nsfw: false, stickied: false,
                    embedTitle: "I am an example of a website preview.\nCustomize me!", embedDescription: nil, embedHTML: nil,
                    thumbnailURL: URL(string: "https://lemmy.ml/pictrs/image/1b759945-6651-497c-bee0-9bdb68f4a829.png")!, apID: "https://lemmy.ml/post/1011068", local: true, postedAt: "2023-05-07T16:48:56.582173", numberOfComments: 0, score: 0, upvotes: 0, downvotes: 0, myVote: .upvoted, hotRank: nil, hotRankActive: nil, newestActivityTime: nil, author: User(id: 0, name: "", displayName: nil, avatarLink: nil, bannerLink: nil, inboxLink: nil, bio: nil, banned: false, actorID: URL(string: "/")!, local: true, deleted: false, admin: false, bot: false, onInstanceID: 0), community: Community(id: 0, name: "", title: nil, description: nil, icon: nil, banner: nil, createdAt: nil, updatedAt: nil, actorID: URL(string: "/")!, local: true, deleted: false, nsfw: false)))
                .padding(.horizontal)
                
                SettingsItem(
                    settingPictureSystemName: "photo.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show website image",
                    isTicked: $shouldShowWebsitePreviews
                )
                SettingsItem(
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
                SettingsItem(
                    settingPictureSystemName: "network",
                    settingPictureColor: .pink,
                    settingName: "Show website address",
                    isTicked: $shouldShowWebsiteHost
                )
            }
            Section("Posts")
            {
                SettingsItem(
                    settingPictureSystemName: "wifi.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show dynamic website icons",
                    isTicked: $shouldShowWebsiteFavicons
                )
                .disabled(!shouldShowWebsiteFaviconAtAll)
                
                HStack {
                    Image(systemName: "tv.circle.fill")
                        .foregroundColor(.pink)
                    
                    Picker("Post display type", selection: $postDisplayType) {
                        ForEach(PostDisplayOptions.allCases, id: \.rawValue)
                        { displayType in
                            Text(displayType.localizedName)
                                .tag(displayType)
                        }
                    }
                }
            }
            
            Section("Communities")
            {
                SettingsItem(
                    settingPictureSystemName: "rectangle.grid.1x2",
                    settingPictureColor: .pink,
                    settingName: "Show community headers",
                    isTicked: $shouldShowCommunityHeaders
                )
            }
            
            Section("Icons")
            {
                SettingsItem(
                    settingPictureSystemName: "person.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show user avatars",
                    isTicked: $shouldShowUserAvatars
                )
                
                SettingsItem(
                    settingPictureSystemName: "person.2.circle.fill",
                    settingPictureColor: .pink,
                    settingName: "Show community icons",
                    isTicked: $shouldShowCommunityIcons
                )
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.inline)
    }
}
