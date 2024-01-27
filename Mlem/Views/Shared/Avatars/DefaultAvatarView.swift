//
//  DefaultAvatarView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-10-02.
//

import Foundation
import SwiftUI

struct DefaultAvatarView: View {
    let avatarType: AvatarType
    
    // TODO: iOS 16 deprecation - just use Color.gray.gradient here
    static let backgroundColor = Color(rgba: 0x8E8E93FF).gradient
    
    var body: some View {
        switch avatarType {
        case .instance:
            ZStack {
                Circle()
                    .fill(DefaultAvatarView.backgroundColor)
                GeometryReader { frame in
                    Image(systemName: avatarType.iconNameFill)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, frame.size.width * 0.2)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        default:
            Image(systemName: avatarType.iconNameFill)
                .resizable()
                .scaledToFill()
                .symbolRenderingMode(.multicolor)
                .foregroundStyle(DefaultAvatarView.backgroundColor, .white)
        }
    }
}

#Preview {
    VStack(spacing: 50) {
        DefaultAvatarView(avatarType: .user)
            .frame(width: 100, height: 100)
        DefaultAvatarView(avatarType: .community)
            .frame(width: 100, height: 100)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}
