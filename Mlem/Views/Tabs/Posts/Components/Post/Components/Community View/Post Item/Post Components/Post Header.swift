//
//  Post Header.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-11.
//

import Foundation
import SwiftUI
import CachedAsyncImage

struct PostHeader: View {
    // appstorage
    @AppStorage("shouldShowUserServerInPost") var shouldShowUserServerInPost: Bool = false
    
    // parameters
    var postView: APIPostView

    // constants
    private let communityIconSize: CGFloat = 32
    private let defaultCommunityIconSize: CGFloat = 24 // a little smaller so it looks nice

    // computed
    // computed
    var usernameColor: Color {
        if postView.creator.admin {
            return .red
        }
        if postView.creator.botAccount {
            return .indigo
        }

        return .secondary
    }

    var body: some View {
        HStack {
            HStack(spacing: 4) {
                // community avatar and name
                NavigationLink(value: postView.community) {
                    HStack {
                        communityAvatar
                            .frame(width: communityIconSize, height: communityIconSize)
                            .clipShape(Circle())
                            .overlay(Circle()
                                .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
                        Text(postView.community.name)
                            .bold()
                    }
                }
                Text("by")
                UserProfileLink(user: postView.creator,
                                serverInstanceLocation: shouldShowUserServerInPost ? .bottom : .disabled)
            }

            Spacer()

            if postView.post.featuredLocal {
                StickiedTag(tagType: .local)
            } else if postView.post.featuredCommunity {
                StickiedTag(tagType: .community)
            }

            if postView.post.nsfw {
                NSFWTag(compact: false)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isStaticText)
        .accessibilityLabel("in \(postView.community.name) by \(postView.creator.name)")
        .font(.subheadline)
        .foregroundColor(.secondary)
    }

    @ViewBuilder
    private var communityAvatar: some View {
        Group {
            if let communityAvatarLink = postView.community.icon {
                CachedAsyncImage(url: communityAvatarLink, urlCache: AppConstants.urlCache) { image in
                    if let avatar = image.image {
                        avatar
                            .resizable()
                            .scaledToFit()
                            .frame(width: communityIconSize, height: communityIconSize)
                    } else {
                        Image("Default Community")
                            .resizable()
                            .scaledToFit()
                            .frame(width: defaultCommunityIconSize, height: defaultCommunityIconSize)
                    }
                }
            } else {
                Image("Default Community")
                    .resizable()
                    .scaledToFit()
                    .frame(width: defaultCommunityIconSize, height: defaultCommunityIconSize)
            }
        }
        .accessibilityHidden(true)
    }
}
