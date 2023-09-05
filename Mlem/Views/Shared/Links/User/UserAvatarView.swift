//
//  UserAvatarView.swift
//  Mlem
//
//  Created by Sjmarf on 05/09/2023.
//

import SwiftUI

struct UserAvatarView: View {
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    @AppStorage("userIconShape") var iconShape: IconShape = .circle

    let user: APIPerson
    let avatarSize: CGFloat
    var lineColor: Color?
    var blurAvatar: Bool

    var shape: AnyShape {
        if iconShape == .circle {
            AnyShape(Circle())
        } else {
            AnyShape(RoundedRectangle(cornerRadius: AppConstants.smallItemCornerRadius))
        }
    }

    var body: some View {
        Group {
            if let url = user.avatar {
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
        .blur(radius: (blurAvatar && shouldBlurNsfw) ? 4 : 0)
        .clipShape(shape)
        .overlay(shape
            .stroke(
                lineColor ?? Color(UIColor.secondarySystemBackground),
                lineWidth: 1
            ))
    }

    private func defaultAvatar() -> AnyView {
        AnyView(
            ZStack {
                VStack {
                    Spacer()
                    Image(systemName: "person.fill")
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
