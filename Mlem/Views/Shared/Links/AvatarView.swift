//
//  AvatarView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//
import SwiftUI

struct AvatarView: View {
    // Don't clip the avatars of communities from these instances
    static let unclippedInstances = ["beehaw.org"]
    
    let type: AvatarType
    let url: URL?
    let avatarSize: CGFloat
    let lineColor: Color
    let lineWidth: CGFloat
    let clipAvatar: Bool
    let blurAvatar: Bool
    let iconResolution: Int
    
    init(
        url: URL?,
        type: AvatarType,
        avatarSize: CGFloat,
        blurAvatar: Bool = false,
        clipAvatar: Bool = true,
        lineColor: Color? = nil,
        lineWidth: CGFloat = 1,
        iconResolution: Int? = nil
    ) {
        @AppStorage("shouldBlurNsfw") var shouldBlurNsfw = true
        self.type = type
        self.url = url
        self.avatarSize = avatarSize
        self.lineColor = lineColor ?? Color(UIColor.secondarySystemBackground)
        self.lineWidth = lineWidth
        self.clipAvatar = clipAvatar
        self.blurAvatar = shouldBlurNsfw && blurAvatar
        self.iconResolution = iconResolution ?? Int(avatarSize * 2)
    }
    
    init(
        community: CommunityModel,
        avatarSize: CGFloat,
        lineColor: Color? = nil,
        lineWidth: CGFloat = 1,
        iconResolution: Int? = nil
    ) {
        self.init(
            url: community.avatar,
            type: .community,
            avatarSize: avatarSize,
            blurAvatar: community.nsfw,
            clipAvatar: AvatarView.shouldClipCommunityAvatar(url: community.avatar),
            lineColor: lineColor,
            lineWidth: lineWidth,
            iconResolution: iconResolution
        )
    }
    
    init(
        user: UserModel,
        avatarSize: CGFloat,
        blurAvatar: Bool = false,
        lineColor: Color? = nil,
        lineWidth: CGFloat = 1,
        iconResolution: Int? = nil
    ) {
        self.init(
            url: user.avatar,
            type: .user,
            avatarSize: avatarSize,
            blurAvatar: blurAvatar,
            lineColor: lineColor,
            lineWidth: lineWidth,
            iconResolution: iconResolution
        )
    }
    
    static func shouldClipCommunityAvatar(url: URL?) -> Bool {
        guard let hostString = url?.host else {
            return true
        }

        return !unclippedInstances.contains(hostString)
    }
    
    var body: some View {
        CachedImage(
            url: url?.withIconSize(iconResolution),
            shouldExpand: false,
            fixedSize: CGSize(width: avatarSize, height: avatarSize),
            imageNotFound: { AnyView(DefaultAvatarView(avatarType: type)) },
            contentMode: .fill
        )
        .frame(width: avatarSize, height: avatarSize)
        .accessibilityHidden(true)
        .blur(radius: blurAvatar ? 4 : 0)
        .clipShape(Circle())
        .overlay(Circle()
            .stroke(
                lineColor,
                lineWidth: clipAvatar ? lineWidth : 0
            ))
    }
}
