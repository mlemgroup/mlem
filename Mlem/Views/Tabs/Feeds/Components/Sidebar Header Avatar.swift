//
//  Sidebar Header Avatar.swift
//  Mlem
//
//  Created by Jake Shirley on 6/21/23.
//

import Foundation

import SwiftUI

struct CommunitySidebarHeaderAvatar: View {
    @State var shouldClipAvatar: Bool = false
    @State var imageUrl: URL?

    var body: some View {
        avatar
            .frame(width: AppConstants.hugeAvatarSize, height: AppConstants.hugeAvatarSize)
            .clipShape(Circle())
            .overlay(Circle()
                .stroke(.secondary, lineWidth: shouldClipAvatar ? 2 : 0))
            .shadow(radius: 10)
            .background(shouldClipAvatar ? Circle()
                .foregroundColor(.systemBackground) : nil)
    }
    
    @ViewBuilder
    var avatar: some View {
        if let avatarURL = imageUrl {
            CachedImage(
                url: avatarURL,
                shouldExpand: false,
                fixedSize: CGSize(width: AppConstants.hugeAvatarSize, height: AppConstants.hugeAvatarSize),
                contentMode: .fill
            )
        } else {
            VStack(alignment: .center) {
                Spacer()
                    .frame(height: 20)
                Image(systemName: Icons.user)
                    .font(.system(size: AppConstants.hugeAvatarSize)) // SF Symbols are apparently font
                    .foregroundColor(.secondary)
            }
        }
    }
}
