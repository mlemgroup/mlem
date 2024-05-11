//
//  AvatarBannerView.swift
//  Mlem
//
//  Created by Sjmarf on 09/05/2024.
//

import MlemMiddleware
import NukeUI
import SwiftUI

struct AvatarBannerView: View {
    var model: (any ProfileProviding)?
    var type: AvatarType
    var showEmptyBanner: Bool = false
    var showBanner: Bool = true
    var showAvatar: Bool = true

    init<T: ProfileProviding>(_ model: T?, showEmptyBanner: Bool = false) {
        self.model = model
        self.type = T.avatarType
        self.showEmptyBanner = showEmptyBanner
    }
    
    init(_ model: any ProfileProviding, showEmptyBanner: Bool = false) {
        self.model = model
        self.type = Swift.type(of: model).avatarType
        self.showEmptyBanner = showEmptyBanner
    }
    
    init(_ model: (any ProfileProviding)?, type: AvatarType, showEmptyBanner: Bool = false) {
        self.model = model
        self.type = type
        self.showEmptyBanner = showEmptyBanner
    }
    
    static let bannerHeight: CGFloat = 170
    static let avatarOverdraw: CGFloat = 40
    static let avatarSize: CGFloat = 108
    static let avatarPadding: CGFloat = AppConstants.standardSpacing
    
    var body: some View {
        Group {
            if model?.banner != nil || showEmptyBanner, showBanner {
                ZStack(alignment: .bottom) {
                    VStack {
                        LazyImage(url: model?.banner) { state in
                            VStack {
                                if let image = state.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipped()
                                } else {
                                    Color(uiColor: .secondarySystemFill)
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
    
    @ViewBuilder
    var avatarView: some View {
        AvatarView(url: model?.avatar, type: type)
            .frame(height: AvatarBannerView.avatarSize)
    }
}
