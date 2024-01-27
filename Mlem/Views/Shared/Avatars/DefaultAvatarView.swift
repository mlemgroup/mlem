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
    
    var body: some View {
        switch avatarType {
        case .instance:
            ZStack {
                Circle()
                    .fill(Color.gray.gradient)
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
                .foregroundStyle(Color.gray.gradient, .white)
        }
    }
}

#Preview {
    VStack(spacing: 50) {
        DefaultAvatarView(avatarType: .user)
            .frame(width: 100, height: 100)
        DefaultAvatarView(avatarType: .community)
            .frame(width: 100, height: 100)
        DefaultAvatarView(avatarType: .instance)
            .frame(width: 100, height: 100)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(.black)
}
