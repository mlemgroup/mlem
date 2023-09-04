//
//  CommunityAvatarView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//
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

struct CommunityAvatarView: View {
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("communityIconShape") var communityIconShape: IconShape = .circle

    let community: APICommunity
    let avatarSize: CGFloat
    var lineColor: Color?

    var blurAvatar: Bool { shouldBlurNsfw && community.nsfw }
    
    var shape: AnyShape {
        if communityIconShape == .circle {
            AnyShape(Circle())
        } else {
            AnyShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
        }
    }

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
        .clipShape(shape)
        .overlay(shape
            .stroke(
                lineColor ?? Color(UIColor.secondarySystemBackground),
                lineWidth: shouldClipAvatar(community: community) ? 1 : 0
            ))
    }

    private func defaultAvatar() -> AnyView {
        AnyView(
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
                    shape
                        .frame(width: avatarSize * 0.83, height: avatarSize * 0.83)
                )
            }
            .frame(maxWidth: .infinity)
            .background(.gray)
        )
    }
}
