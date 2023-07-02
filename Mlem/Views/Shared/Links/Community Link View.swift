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
    // SETTINGS
    // TODO: setting for showing community server instance
    let showServerInstance: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    let community: APICommunity
    
    var body: some View {
        NavigationLink(value: community) {
            HStack(alignment: .bottom, spacing: AppConstants.largeAvatarSpacing) {
                if shouldShowCommunityIcons {
                    communityAvatar
                }
                
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
            .accessibilityElement(children: .combine)
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
                        defaultCommunityAvatar()
                    }
                }
            } else {
                defaultCommunityAvatar()
            }
        }
        .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
        .clipShape(Circle())
        .overlay(Circle()
            .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
        .accessibilityHidden(true)
    }
    
    private func defaultCommunityAvatar() -> some View {
        Image(systemName: "building.2.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
            .foregroundColor(.secondary)
    }
}

struct CommunityLabel: View {
    // SETTINGS
    let showServerInstance: Bool = true
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    let community: APICommunity
    
    var body: some View {
        Group {
            HStack(alignment: .bottom, spacing: AppConstants.largeAvatarSpacing) {
                if shouldShowCommunityIcons {
                    communityAvatar
                }
                
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
            .accessibilityElement(children: .combine)
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
                        defaultCommunityAvatar()
                    }
                }
            } else {
                defaultCommunityAvatar()
            }
        }
        .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
        .clipShape(Circle())
        .overlay(Circle()
            .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
        .accessibilityHidden(true)
    }
    
    private func defaultCommunityAvatar() -> some View {
        Image(systemName: "building.2.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
            .foregroundColor(.secondary)
    }
}
