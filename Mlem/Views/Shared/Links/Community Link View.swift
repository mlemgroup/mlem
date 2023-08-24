//
//  Community Link.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-27.
//

import Foundation
import SwiftUI

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
    
    init(
        community: APICommunity,
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
                CommunityLabel(
                    community: community,
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
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    // parameters
    let community: APICommunity
    let serverInstanceLocation: ServerInstanceLocation
    let overrideShowAvatar: Bool? // if present, shows or hides the avatar according to value; otherwise uses system setting
    
    // computed
    var blurAvatar: Bool { shouldBlurNsfw && community.nsfw }
    var avatarSize: CGSize { serverInstanceLocation == .bottom
        ? CGSize(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
        : CGSize(width: AppConstants.smallAvatarSize, height: AppConstants.smallAvatarSize)
    }

    var showAvatar: Bool {
        if let overrideShowAvatar {
            return overrideShowAvatar
        } else {
            return shouldShowCommunityIcons
        }
    }
    
    init(
        community: APICommunity,
        serverInstanceLocation: ServerInstanceLocation,
        overrideShowAvatar: Bool? = nil
    ) {
        self.community = community
        self.serverInstanceLocation = serverInstanceLocation
        self.overrideShowAvatar = overrideShowAvatar
    }
    
    var body: some View {
        Group {
            HStack(alignment: .bottom, spacing: AppConstants.largeAvatarSpacing) {
                if showAvatar {
                    communityAvatar
                        .blur(radius: blurAvatar ? 4 : 0)
                        .clipShape(Circle())
                        .overlay(Circle()
                            .stroke(
                                Color(UIColor.secondarySystemBackground),
                                lineWidth: shouldClipAvatar(community: community) ? 1 : 0
                            ))
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
            .foregroundColor(.secondary)
    }
    
    @ViewBuilder
    private var communityInstance: some View {
        if let host = community.actorId.host() {
            Text("@\(host)")
                .dynamicTypeSize(.small ... .accessibility2)
                .lineLimit(1)
                .foregroundColor(Color(uiColor: .tertiaryLabel))
                .font(.caption)
                .allowsHitTesting(false)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private var communityAvatar: some View {
        Group {
            if let url = community.icon {
                CachedImage(
                    url: url.withIcon64Parameters,
                    shouldExpand: false,
                    fixedSize: avatarSize,
                    imageNotFound: defaultCommunityAvatar,
                    contentMode: .fill
                )
            } else {
                defaultCommunityAvatar()
            }
        }
        .frame(width: avatarSize.width, height: avatarSize.height)
        .accessibilityHidden(true)
    }
    
    private func defaultCommunityAvatar() -> AnyView {
        AnyView(Image(systemName: "building.2.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: avatarSize.width, height: avatarSize.height)
            .foregroundColor(.secondary)
        )
    }
}
