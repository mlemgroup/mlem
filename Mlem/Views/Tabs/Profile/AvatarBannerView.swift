//
//  UserHeaderView.swift
//  Mlem
//
//  Created by Sjmarf on 27/12/2023.
//

import SwiftUI
import NukeUI

struct AvatarBannerView: View {
    
    let type: AvatarType
    
    let avatar: URL?
    let banner: URL?
    
    let showBanner: Bool
    let showAvatar: Bool
    
    init(user: UserModel) {
        self.type = .user
        self.avatar = user.avatar
        self.banner = user.banner
        @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
        self.showBanner = shouldShowUserHeaders
        @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
        self.showAvatar = shouldShowUserAvatars
    }
    
    init(community: CommunityModel) {
        self.type = .community
        self.avatar = community.avatar
        self.banner = community.banner
        @AppStorage("shouldShowCommunityHeaders") var shouldShowCommunityHeaders: Bool = true
        self.showBanner = shouldShowCommunityHeaders
        @AppStorage("shouldShowCommunityIcons") var shouldShowCommunityIcons: Bool = true
        self.showAvatar = shouldShowCommunityIcons
    }
    
    static let bannerHeight: CGFloat = 170
    static let avatarOverdraw: CGFloat = 40
    static let avatarSize: CGFloat = 108
    static let avatarPadding: CGFloat = AppConstants.postAndCommentSpacing
    
    var avatarView: some View {
        AvatarView(
            url: avatar,
            type: type,
            avatarSize: AvatarBannerView.avatarSize,
            lineWidth: 0,
            iconResolution: .unrestricted
        )
    }
    
    var body: some View {
        Group {
            if let banner, showBanner {
                ZStack(alignment: .bottom) {
                    VStack {
                        LazyImage(url: banner) { state in
                            VStack {
                                if let image = state.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                } else {
                                    Color.secondarySystemBackground
                                }
                            }
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .frame(height: AvatarBannerView.bannerHeight)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius))
                            .mask {
                                ZStack(alignment: .bottom) {
                                    Color.black
                                    if showAvatar {
                                        Circle()
                                            .frame(
                                                width: AvatarBannerView.avatarSize + AvatarBannerView.avatarPadding * 2,
                                                height: AvatarBannerView.avatarSize + AvatarBannerView.avatarPadding * 2
                                            )
                                            .offset(y: AvatarBannerView.avatarOverdraw + AvatarBannerView.avatarPadding)
                                            .blendMode(.destinationOut)
                                    }
                                }
                                .compositingGroup()
                            }
                            
                        }
                        Spacer()
                    }
                    .overlay {
                        if showAvatar {
                            avatarView
                                .frame(maxHeight: .infinity, alignment: .bottom)
                        }
                    }
                }
                .frame(height: AvatarBannerView.bannerHeight + (showAvatar ? AvatarBannerView.avatarOverdraw : 0))
            } else {
                if showAvatar {
                    avatarView
                        .padding(.top)
                }
            }
        }
    }
}
