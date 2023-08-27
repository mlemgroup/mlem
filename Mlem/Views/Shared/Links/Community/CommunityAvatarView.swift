//
//  CommunityAvatarView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//

import SwiftUI

struct CommunityAvatarView: View {
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    let community: APICommunity
    let avatarSize: CGFloat
    
    var blurAvatar: Bool { shouldBlurNsfw && community.nsfw }
    
    var body: some View {
        Group {
            if let url = community.icon {
                CachedImage(
                    url: url.withIcon64Parameters,
                    shouldExpand: false,
                    fixedSize: CGSize(width: avatarSize, height: avatarSize),
                    imageNotFound: defaultAvatar,
                    contentMode: .fill
                )
            } else {
                defaultAvatar()
            }
        }
        .frame(width: avatarSize, height: avatarSize)
        .accessibilityHidden(true)
        .blur(radius: blurAvatar ? 4 : 0)
        .clipShape(Circle())
        .overlay(Circle()
            .stroke(
                Color(UIColor.secondarySystemBackground),
                lineWidth: shouldClipAvatar(community: community) ? 1 : 0
            ))
    }
    
    private func defaultAvatar() -> AnyView {
        AnyView(Image(systemName: "building.2.crop.circle.fill")
            .resizable()
            .scaledToFit()
            .frame(width: avatarSize, height: avatarSize)
            .foregroundColor(.secondary)
        )
    }
}
