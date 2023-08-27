//
//  UserAvatarView.swift
//  Mlem
//
//  Created by Sjmarf on 27/08/2023.
//

import SwiftUI

struct UserAvatarView: View {
    @AppStorage("shouldBlurNsfw") var shouldBlurNsfw: Bool = true
    
    let user: APIPerson
    let avatarSize: CGFloat
    
    var blurAvatar: Bool = true
    
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
        .blur(radius: (shouldBlurNsfw && blurAvatar) ? 4 : 0)
        .clipShape(Circle())
        .overlay(Circle()
            .stroke(
                Color(UIColor.secondarySystemBackground),
                lineWidth: 1
            ))
    }
    
    private func defaultAvatar() -> AnyView {
        AnyView(Image(systemName: "person.circle")
            .resizable()
            .scaledToFill()
            .frame(width: avatarSize, height: avatarSize)
            .foregroundColor(.secondary)
        )
    }
}
