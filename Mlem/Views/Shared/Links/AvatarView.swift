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
    let clipAvatar: Bool
    let blurAvatar: Bool
    let iconResolution: Int
    
    init(
        community: CommunityModel,
        avatarSize: CGFloat,
        lineColor: Color? = nil,
        iconResolution: Int? = nil
    ) {
        @AppStorage("shouldBlurNsfw") var shouldBlurNsfw = true
        
        self.type = .community
        self.url = community.avatar
        self.avatarSize = avatarSize
        self.lineColor = lineColor ?? Color(UIColor.secondarySystemBackground)
        self.clipAvatar = AvatarView.shouldClipCommunityAvatar(url: community.avatar)
        self.blurAvatar = shouldBlurNsfw && community.nsfw
        self.iconResolution = iconResolution ?? Int(avatarSize * 2)
    }
    
    init(
        user: UserModel,
        avatarSize: CGFloat,
        blurAvatar: Bool = false,
        lineColor: Color? = nil,
        iconResolution: Int? = nil
    ) {
        @AppStorage("shouldBlurNsfw") var shouldBlurNsfw = true
        
        self.type = .user
        self.url = user.avatar
        self.avatarSize = avatarSize
        self.lineColor = lineColor ?? Color(UIColor.secondarySystemBackground)
        self.clipAvatar = false
        self.blurAvatar = shouldBlurNsfw && blurAvatar
        self.iconResolution = iconResolution ?? Int(avatarSize * 2)
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
                lineWidth: clipAvatar ? 1 : 0
            ))
    }
}
