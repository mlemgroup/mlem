//
//  Community Link.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-27.
//

import Foundation
import SwiftUI
import CachedAsyncImage

struct CommunityLinkView: View {
    // TODO: setting
    let showServerInstance: Bool = true
    
    let community: APICommunity
    
    var body: some View {
        NavigationLink(value: community) {
            HStack(alignment: .bottom, spacing: AppConstants.largeAvatarSpacing) {
                communityAvatar
                
                VStack(alignment: .leading) {
                    Text(community.name)
                        .font(.footnote)
                        .bold()
                    if showServerInstance, let host = community.actorId.host() {
                        Text("@\(host)")
                            .minimumScaleFactor(0.01)
                            .lineLimit(1)
                            .opacity(0.6)
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder
    private var communityAvatar: some View {
        Group {
            if let communityAvatarLink = community.icon {
                CachedAsyncImage(url: communityAvatarLink, urlCache: AppConstants.urlCache) { image in
                    if let avatar = image.image {
                        avatar
                            .resizable()
                            .scaledToFit()
                            .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                    } else {
                        Image("Default Community")
                            .resizable()
                            .scaledToFit()
                            .frame(width: AppConstants.defaultAvatarSize, height: AppConstants.defaultAvatarSize)
                    }
                }
            } else {
                Image("Default Community")
                    .resizable()
                    .scaledToFit()
                    .frame(width: AppConstants.defaultAvatarSize, height: AppConstants.defaultAvatarSize)
            }
        }
        .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
        .clipShape(Circle())
        .overlay(Circle()
            .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
        .accessibilityHidden(true)
    }
}
