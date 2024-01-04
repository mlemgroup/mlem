//
//  UserHeaderView.swift
//  Mlem
//
//  Created by Sjmarf on 27/12/2023.
//

import SwiftUI
import NukeUI

struct UserHeaderView: View {
    @AppStorage("shouldShowUserHeaders") var shouldShowUserHeaders: Bool = true
    @AppStorage("shouldShowUserAvatars") var shouldShowUserAvatars: Bool = true
    
    let user: UserModel
    
    static let bannerHeight: CGFloat = 170
    static let avatarOverdraw: CGFloat = 40
    static let avatarSize: CGFloat = 108
    static let avatarPadding: CGFloat = AppConstants.postAndCommentSpacing
    
    var body: some View {
        Group {
            if let banner = user.banner, shouldShowUserHeaders {
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
                            .frame(height: UserHeaderView.bannerHeight)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: AppConstants.largeItemCornerRadius))
                            .mask {
                                ZStack(alignment: .bottom) {
                                    Color.black
                                    if shouldShowUserAvatars {
                                        Circle()
                                            .frame(
                                                width: UserHeaderView.avatarSize + UserHeaderView.avatarPadding * 2,
                                                height: UserHeaderView.avatarSize + UserHeaderView.avatarPadding * 2
                                            )
                                            .offset(y: UserHeaderView.avatarOverdraw + UserHeaderView.avatarPadding)
                                            .blendMode(.destinationOut)
                                    }
                                }
                                .compositingGroup()
                            }
                            
                        }
                        Spacer()
                    }
                    if shouldShowUserAvatars {
                        AvatarView(user: user, avatarSize: UserHeaderView.avatarSize, lineWidth: 0, iconResolution: .unrestricted)
                    }
                }
                .frame(height: UserHeaderView.bannerHeight + (shouldShowUserAvatars ? UserHeaderView.avatarOverdraw : 0))
            } else {
                if shouldShowUserAvatars {
                    AvatarView(user: user, avatarSize: UserHeaderView.avatarSize, lineWidth: 0, iconResolution: .unrestricted)
                        .padding(.top)
                }
            }
        }
    }
}
