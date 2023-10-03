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

    var imageName: String {
        switch avatarType {
        case .user:
            return Icons.user
        case .community:
            return Icons.community
        }
    }
    
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
        CachedImage(
            url: imageUrl,
            shouldExpand: false,
            fixedSize: CGSize(width: AppConstants.hugeAvatarSize, height: AppConstants.hugeAvatarSize),
            imageNotFound: fallbackAvatar,
            contentMode: .fill
        )
    }
    
    func fallbackAvatar() -> AnyView {
        AnyView(
            Image(systemName: imageName)
                .font(.system(size: AppConstants.hugeAvatarSize)) // SF Symbols are apparently font
                .foregroundStyle(Color.gray.gradient)
        )
    }
}
