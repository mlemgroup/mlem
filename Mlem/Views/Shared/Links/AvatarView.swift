//
//  AvatarView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//
import SwiftUI

enum AvatarIconResolution {
    case unrestricted
    case fixed(Int)
}

struct AvatarView: View {
    // Don't show the outline for avatars of communities from these instances
    static let noOutlineInstances = ["beehaw.org"]
    
    let type: AvatarType
    let url: URL?
    let avatarSize: CGFloat
    let lineColor: Color
    let lineWidth: CGFloat
    let blurAvatar: Bool
    
    init(
        url: URL?,
        type: AvatarType,
        avatarSize: CGFloat,
        blurAvatar: Bool = false,
        lineColor: Color? = nil,
        lineWidth: CGFloat = 1,
        iconResolution: AvatarIconResolution? = nil
    ) {
        @AppStorage("shouldBlurNsfw") var shouldBlurNsfw = true
        self.type = type
        
        self.avatarSize = avatarSize
        self.lineColor = lineColor ?? Color(UIColor.secondarySystemBackground)
        self.lineWidth = lineWidth
        self.blurAvatar = shouldBlurNsfw && blurAvatar
        switch iconResolution {
            
        case .fixed(let pixels):
            self.url = url?.withIconSize(pixels)
        case .unrestricted:
            self.url = url
        case nil:
            self.url = url?.withIconSize(Int(avatarSize * 2))
        }
    }
    
    init(
        community: CommunityModel,
        avatarSize: CGFloat,
        lineColor: Color? = nil,
        lineWidth: CGFloat = 1,
        iconResolution: AvatarIconResolution? = nil
    ) {
        self.init(
            url: community.avatar,
            type: .community,
            avatarSize: avatarSize,
            blurAvatar: community.nsfw,
            lineColor: lineColor,
            lineWidth: AvatarView.shouldShowCommunityAvatarOutline(url: community.avatar) ? lineWidth : 0,
            iconResolution: iconResolution
        )
    }
    
    init(
        user: UserModel,
        avatarSize: CGFloat,
        blurAvatar: Bool = false,
        lineColor: Color? = nil,
        lineWidth: CGFloat = 1,
        iconResolution: AvatarIconResolution? = nil
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
    
    init(
        instance: InstanceModel,
        avatarSize: CGFloat,
        blurAvatar: Bool = false,
        lineColor: Color? = nil,
        lineWidth: CGFloat = 1,
        iconResolution: AvatarIconResolution? = nil
    ) {
        self.init(
            url: instance.avatar,
            type: .instance,
            avatarSize: avatarSize,
            blurAvatar: blurAvatar,
            lineColor: lineColor,
            lineWidth: lineWidth,
            iconResolution: iconResolution
        )
    }
    
    static func shouldShowCommunityAvatarOutline(url: URL?) -> Bool {
        guard let hostString = url?.host else {
            return true
        }

        return !noOutlineInstances.contains(hostString)
    }
    
    var body: some View {
        CachedImage(
            url: url,
            shouldExpand: false,
            fixedSize: CGSize(width: avatarSize, height: avatarSize),
            imageNotFound: { AnyView(DefaultAvatarView(avatarType: type)) },
            blurRadius: blurAvatar ? 4 : 0,
            contentMode: .fill
        )
        .frame(width: avatarSize, height: avatarSize)
        .accessibilityHidden(true)
        .clipShape(Circle())
        .overlay(Circle()
            .stroke(
                lineColor,
                lineWidth: lineWidth
            ))
    }
}
