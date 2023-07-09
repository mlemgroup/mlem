//
//  CustomizePostView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-08.
//

import Foundation
import SwiftUI

struct CustomizePostView: View {
    @AppStorage("postSize") var postSize: PostSize = PostSize.headline
    @AppStorage("shouldShowPostThumbnails") var shouldShowPostThumbnails: Bool = false
    @AppStorage("shouldShowCommunityServerInPost") var shouldShowCommunityServerInPost: Bool = false
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = false
    @AppStorage("shouldShowPostCreator") var shouldShowPostCreator: Bool = true
    
    @State var postPresented: TmpPostType = .titleOnly
    
    enum TmpPostType: String, CaseIterable {
        case titleOnly, text, image, link
        
        var label: String {
            if self == .titleOnly { return "Title Only" }
            return self.rawValue.capitalized
        }
        var id: Self { self }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            Divider()
            
            mockupPost
                .background(Color(UIColor.systemBackground))
            
            Divider()
            
            Picker(selection: $postPresented) {
                ForEach(TmpPostType.allCases, id: \.id) { tab in
                    Text(tab.label).tag(tab)
                }
            } label: {
                Text("Post Type")
            }
            .pickerStyle(.segmented)
            .padding()
            
            List {
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
        }
        .background(Color(UIColor.secondarySystemBackground))
        .navigationTitle("Customize Post Display")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    var mockupPost: some View {
        if postSize == .compact {
            UltraCompactPost(postView: dummyPost, account: dummyAccount, showCommunity: true, menuFunctions: [])
        } else {
            VStack(alignment: .leading, spacing: AppConstants.postAndCommentSpacing) {
                // community name
                // TEMPORARILY DISABLED: conditionally showing based on community
                // if showCommunity {
                //    CommunityLinkView(community: postView.community)
                // }
                HStack {
                    CommunityLinkView(community: dummyPost.community)
                    
                    Spacer()
                    
                    EllipsisMenu(size: 24, menuFunctions: [])
                }
                
                if postSize == .headline {
                    CompactPost(postView: dummyPost,
                        account: dummyAccount
                    )
                } else {
                    LargePost(
                        postView: dummyPost,
                        isExpanded: false
                    )
                }
                
                // posting user
                if shouldShowPostCreator {
                    UserProfileLink(user: dummyPost.creator, serverInstanceLocation: .bottom)
                }
                
                PostInteractionBar(postView: dummyPost,
                                   account: dummyAccount,
                                   menuFunctions: [],
                                   voteOnPost: doNothingScoringOp,
                                   updatedSavePost: doNothingBool,
                                   deletePost: doNothing,
                                   replyToPost: doNothing)
            }
        }
    }
    
    func doNothing() { }
    func doNothingScoringOp(op: ScoringOperation) async { }
    func doNothingBool(bool: Bool) async { }
    
    let dummyAccount: SavedAccount =  SavedAccount(id: 0,
                                                   instanceLink: URL(string: "lemmy.ml/u/ericbandrews")!,
                                                   accessToken: "",
                                                   username: "Eric")
    
    let dummyPost: APIPostView = APIPostView(
        post: APIPost(id: 0,
                      name: "Test post",
                      url: nil,
                      body: "I am an example post. I exist to show you how a post might look in the feed. Isn't that neat?",
                      creatorId: 0,
                      communityId: 0,
                      deleted: false,
                      embedDescription: nil,
                      embedTitle: nil,
                      embedVideoUrl: nil,
                      featuredCommunity: false,
                      featuredLocal: false,
                      languageId: 0,
                      apId: "",
                      local: false,
                      locked: false,
                      nsfw: false,
                      published: Date.now,
                      removed: false,
                      thumbnailUrl: nil,
                      updated: nil),
        creator: APIPerson(id: 0,
                           name: "SomeLemmyUser",
                           displayName: "Lemmy User",
                           avatar: nil,
                           banned: false,
                           published: Date.now,
                           updated: nil,
                           actorId: URL(string: "lemmy.ml/u/ericbandrews")!,
                           bio: nil,
                           local: false,
                           banner: nil,
                           deleted: false,
                           sharedInboxUrl: nil,
                           matrixUserId: nil,
                           admin: false,
                           botAccount: false,
                           banExpires: nil,
                           instanceId: 0),
        community: APICommunity(id: 0,
                                name: "Some Community",
                                title: "A Lemmy Community",
                                description: "A Lemmy community",
                                published: Date.now,
                                updated: nil,
                                removed: false,
                                deleted: false,
                                nsfw: false,
                                actorId: URL(string: "lemmy.ml/c/mlemapp")!,
                                local: true,
                                icon: nil,
                                banner: nil,
                                hidden: false,
                                postingRestrictedToMods: false,
                                instanceId: 0),
        creatorBannedFromCommunity: false,
        counts: APIPostAggregates(id: 0,
                                  postId: 0,
                                  comments: 47,
                                  score: 473,
                                  upvotes: 581,
                                  downvotes: 108,
                                  published: Date.now,
                                  newestCommentTime: Date.now,
                                  newestCommentTimeNecro: Date.now,
                                  featuredCommunity: false,
                                  featuredLocal: false),
        subscribed: APISubscribedStatus.subscribed,
        saved: false,
        read: false,
        creatorBlocked: false,
        unreadComments: 32)
}
