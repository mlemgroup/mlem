//
//  AvatarBannerView.swift
//  Mlem
//
//  Created by Sjmarf on 09/05/2024.
//

import MlemMiddleware
import NukeUI
import Rest
import SwiftUI

struct AvatarBannerView: View {
    @Setting(\.media_animatedAvatars) var animatedAvatars
    
    var model: (any ProfileProviding)?
    var fallback: MediaView.Fallback
    var showEmptyBanner: Bool = false
    var showBanner: Bool = true
    var showAvatar: Bool = true

    init<T: ProfileProviding>(_ model: T?, showEmptyBanner: Bool = false) {
        self.model = model
        self.fallback = T.avatarFallback
        self.showEmptyBanner = showEmptyBanner
    }
    
    init(_ model: any ProfileProviding, showEmptyBanner: Bool = false) {
        self.model = model
        self.fallback = Swift.type(of: model).avatarFallback
        self.showEmptyBanner = showEmptyBanner
    }
    
    init(_ model: (any ProfileProviding)?, fallback: MediaView.Fallback, showEmptyBanner: Bool = false) {
        self.model = model
        self.fallback = fallback
        self.showEmptyBanner = showEmptyBanner
    }
    
    static let bannerHeight: CGFloat = 170
    static let avatarOverdraw: CGFloat = 40
    static let avatarSize: CGFloat = 108
    static let avatarPadding: CGFloat = Constants.main.standardSpacing
    
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
                            .clipShape(RoundedRectangle(cornerRadius: Constants.main.mediumItemCornerRadius))
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
    
    var avatarView: some View {
        CircleCroppedImageView(
            url: model?.avatar,
            frame: AvatarBannerView.avatarSize,
            fallback: fallback,
            enableAnimation: animatedAvatars != .never
        )
    }
}
