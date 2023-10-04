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
    
    init(community: APICommunity, avatarSize: CGFloat, lineColor: Color? = nil) {
        @AppStorage("shouldBlurNsfw") var shouldBlurNsfw = true
        
        self.type = .community
        self.url = community.iconUrl
        self.avatarSize = avatarSize
        self.lineColor = lineColor ?? Color(UIColor.secondarySystemBackground)
        self.clipAvatar = AvatarView.shouldClipCommunityAvatar(url: community.iconUrl)
        self.blurAvatar = shouldBlurNsfw && community.nsfw
    }
    
    init(user: APIPerson, avatarSize: CGFloat, blurAvatar: Bool = false, lineColor: Color? = nil) {
        @AppStorage("shouldBlurNsfw") var shouldBlurNsfw = true
        
        self.type = .user
        self.url = user.avatarUrl
        self.avatarSize = avatarSize
        self.lineColor = lineColor ?? Color(UIColor.secondarySystemBackground)
        self.clipAvatar = false
        self.blurAvatar = shouldBlurNsfw && blurAvatar
    }
    
    static func shouldClipCommunityAvatar(url: URL?) -> Bool {
        guard let hostString = url?.host else {
            return true
        }

        return !unclippedInstances.contains(hostString)
    }
    
    var body: some View {
        CachedImage(
            url: url?.withIcon64Parameters,
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
