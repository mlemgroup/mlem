//
//  Community Link.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-27.
//

import Foundation
import SwiftUI
import CachedAsyncImage

private let clipOptOut = ["beehaw.org"]

func shouldClipAvatar(community: APICommunity) -> Bool {
    guard let hostString = community.actorId.host else {
        return true
    }
    
    return !clipOptOut.contains(hostString)
}

func shouldClipAvatar(url: URL?) -> Bool {
    guard let hostString = url?.host else {
        return true
    }
    
    return !clipOptOut.contains(hostString)
}

struct CommunityLinkView: View {
    // settings
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    let community: APICommunity
    let serverInstanceLocation: ServerInstanceLocation
    
    init(community: APICommunity, serverInstanceLocation: ServerInstanceLocation = .bottom) {
        self.community = community
        self.serverInstanceLocation = serverInstanceLocation
    }
    
    var body: some View {
        NavigationLink(value: community) {
            CommunityLabel(shouldShowCommunityIcons: shouldShowCommunityIcons,
                           community: community,
                           serverInstanceLocation: serverInstanceLocation
            )
        }
    }
}

struct CommunityLabel: View {
    // settings
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    // parameters
    let community: APICommunity
    let serverInstanceLocation: ServerInstanceLocation
    
    var body: some View {
        Group {
            HStack(alignment: .bottom, spacing: AppConstants.largeAvatarSpacing) {
                if shouldShowCommunityIcons {
                    if shouldClipAvatar(community: community) {
                        communityAvatar
                            .clipShape(Circle())
                            .overlay(Circle()
                                .stroke(Color(UIColor.secondarySystemBackground), lineWidth: 1))
                    } else {
                        communityAvatar
                    }
                }
                
                switch serverInstanceLocation {
                case .disabled:
                    communityName
                case .trailing:
                    HStack(spacing: 0) {
                        communityName
                        communityInstance
                    }
                    .foregroundColor(.secondary)
                case .bottom:
                    VStack(alignment: .leading) {
                        communityName
                        communityInstance
                    }
                    .foregroundColor(.secondary)
                }
                
            }
            .accessibilityElement(children: .combine)
        }
    }
    
    @ViewBuilder
    private var communityName: some View {
        Text(community.name)
            .font(.footnote)
            .bold()
    }
    
    @ViewBuilder
    private var communityInstance: some View {
        if let host = community.actorId.host() {
            Text("@\(host)")
                .minimumScaleFactor(0.01)
                .lineLimit(1)
                .opacity(0.6)
                .font(.caption)
        } else {
            EmptyView()
        }
    }
    
    private func avatarSize() -> CGFloat {
        serverInstanceLocation == .bottom ? AppConstants.largeAvatarSize : AppConstants.smallAvatarSize
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
                            .frame(width: avatarSize(), height: avatarSize())
                    } else {
                        defaultCommunityAvatar()
                    }
                }
            } else {
                defaultCommunityAvatar()
            }
        }
        .frame(width: avatarSize(), height: avatarSize())
        .accessibilityHidden(true)
    }
    
    private func defaultCommunityAvatar() -> some View {
        Image(systemName: "building.2.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: avatarSize(), height: avatarSize())
            .foregroundColor(.secondary)
    }
}
