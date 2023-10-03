//
//  Sidebar Header Avatar.swift
//  Mlem
//
//  Created by Jake Shirley on 6/21/23.
//

import Foundation

import SwiftUI

struct SidebarHeaderAvatar: View {
    @State var shouldClipAvatar: Bool = false
    @State var imageUrl: URL?
    let avatarType: AvatarType
    
    var body: some View {
        CachedImage(
            url: imageUrl,
            shouldExpand: false,
            fixedSize: CGSize(width: AppConstants.hugeAvatarSize, height: AppConstants.hugeAvatarSize),
            imageNotFound: { AnyView(DefaultAvatar(avatarType: avatarType)) },
            contentMode: .fill
        )
        .frame(width: AppConstants.hugeAvatarSize, height: AppConstants.hugeAvatarSize)
        .clipShape(Circle())
        .overlay(Circle()
            .stroke(.secondary, lineWidth: shouldClipAvatar ? 2 : 0))
        .shadow(radius: 10)
        .background(shouldClipAvatar ? Circle()
            .foregroundColor(.systemBackground) : nil)
    }
}
