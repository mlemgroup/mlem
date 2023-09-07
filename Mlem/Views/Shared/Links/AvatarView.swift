//
//  AvatarView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//
import SwiftUI

// Don't clip the avatars of communities from these instances
private let unclippedInstances = ["beehaw.org"]

func shouldClipAvatar(community: APICommunity) -> Bool {
    guard let hostString = community.actorId.host else {
        return true
    }

    return !unclippedInstances.contains(hostString)
}

func shouldClipAvatar(url: URL?) -> Bool {
    guard let hostString = url?.host else {
        return true
    }

    return !unclippedInstances.contains(hostString)
}

struct AvatarView: View {
    
    enum AvatarType { case community, user }
    
    let type: AvatarType
    let url: URL?
    let avatarSize: CGFloat
    let lineColor: Color
    let clipAvatar: Bool
    let blurAvatar: Bool
    
    init(community: APICommunity, avatarSize: CGFloat, lineColor: Color? = nil) {
        @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
        
        self.type = .community
        self.url = community.icon
        self.avatarSize = avatarSize
        self.lineColor = lineColor ?? Color(UIColor.secondarySystemBackground)
        self.clipAvatar = shouldClipAvatar(community: community)
        self.blurAvatar = shouldBlurNsfw && community.nsfw
    }
    
    init(user: APIPerson, avatarSize: CGFloat, blurAvatar: Bool = false, lineColor: Color? = nil) {
        @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
        
        self.type = .user
        self.url = user.avatar
        self.avatarSize = avatarSize
        self.lineColor = lineColor ?? Color(UIColor.secondarySystemBackground)
        self.clipAvatar = false
        self.blurAvatar = shouldBlurNsfw && blurAvatar
    }

    var body: some View {
        Group {
            if let url = url {
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
                lineColor,
                lineWidth: clipAvatar ? 1 : 0
            ))
    }

    private func defaultAvatar() -> AnyView {
        switch type {
        case .community:
            return AnyView(
                ZStack {
                    VStack {
                        Spacer()
                        Image(systemName: "building.2.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: avatarSize * 0.66)
                            .foregroundStyle(.white)
                    }
                    .scaledToFit()
                    .mask(
                        Circle()
                            .frame(width: avatarSize * 0.83, height: avatarSize * 0.83)
                    )
                }
                    .frame(maxWidth: .infinity)
                    .background(.gray)
            )
        case .user:
            return AnyView(
                ZStack {
                    VStack {
                        Spacer()
                        Image(systemName: "person.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: avatarSize * 0.75)
                            .foregroundStyle(.white)
                    }
                    .scaledToFit()
                    .mask(
                        Circle()
                            .frame(width: avatarSize * 0.83, height: avatarSize * 0.83)
                    )
                }
                .frame(maxWidth: .infinity)
                .background(.gray)
            )
        }
    }
}
