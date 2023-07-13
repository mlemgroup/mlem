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
    let community: APICommunity
    let serverInstanceLocation: ServerInstanceLocation
    let extraText: String?
    let overrideShowAvatar: Bool? // if present, shows or hides avatar according to value; otherwise uses system setting
    
    init(community: APICommunity,
         serverInstanceLocation: ServerInstanceLocation = .bottom,
         overrideShowAvatar: Bool? = nil,
         extraText: String? = nil
        ) {
        self.community = community
        self.serverInstanceLocation = serverInstanceLocation
        self.extraText = extraText
        self.overrideShowAvatar = overrideShowAvatar
    }
    
    var body: some View {
        NavigationLink(value: community) {
            HStack {
                CommunityLabel(community: community,
                               serverInstanceLocation: serverInstanceLocation,
                               overrideShowAvatar: overrideShowAvatar
                )
                Spacer()
                if let text = extraText {
                    Text(text)
                }
            }
        }
    }
}

struct CommunityLabel: View {
    // settings
    @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
    
    // parameters
    let community: APICommunity
    let serverInstanceLocation: ServerInstanceLocation
    let overrideShowAvatar: Bool? // if present, shows or hides the avatar according to value; otherwise uses system setting

    var showAvatar: Bool {
        if let overrideShowAvatar = overrideShowAvatar {
            return overrideShowAvatar
        } else {
            return shouldShowCommunityIcons
        }
    }
    
    init(community: APICommunity,
         serverInstanceLocation: ServerInstanceLocation,
         overrideShowAvatar: Bool? = nil) {
        self.community = community
        self.serverInstanceLocation = serverInstanceLocation
        self.overrideShowAvatar = overrideShowAvatar
    }
    
    var body: some View {
        Group {
            HStack(alignment: .bottom, spacing: AppConstants.largeAvatarSpacing) {
                if showAvatar {
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
            .dynamicTypeSize(.small ... .accessibility1)
            .font(.footnote)
            .bold()
    }
    
    @ViewBuilder
    private var communityInstance: some View {
        if let host = community.actorId.host() {
            Text("@\(host)")
                .dynamicTypeSize(.small ... .accessibility2)
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
    
    private func avatarUrl(from: URL) -> URL {
        serverInstanceLocation == .bottom ? from.withIcon64Parameters : from.withIcon32Parameters
    }
    
    @ViewBuilder
    private var communityAvatar: some View {
        Group {
            if let communityAvatarLink = community.icon {
                CachedAsyncImage(url: avatarUrl(from: communityAvatarLink), urlCache: AppConstants.urlCache) { image in
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
