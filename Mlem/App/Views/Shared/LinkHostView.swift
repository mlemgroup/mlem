//
//  LinkHostView.swift
//  Mlem
//
//  Created by Sjmarf on 2025-10-07.
//

import MlemMiddleware
import SwiftUI

struct LinkHostView: View {
    @Setting(\.post_webPreview_showIcon) var showFavicons
    
    let link: PostLink
    let withCapsule: Bool
    
    var body: some View {
        if withCapsule {
            content
                .padding(Constants.main.halfSpacing)
                .padding(showFavicons ? .trailing : .horizontal, 3)
                .background {
                    Capsule()
                        .fill(.regularMaterial)
                        .overlay(Capsule().fill(.themedBackground.opacity(0.25)))
                }
        } else {
            content
        }
    }
    
    var content: some View {
        HStack(spacing: Constants.main.halfSpacing) {
            if showFavicons {
                CircleCroppedImageView(url: link.favicon, frame: Constants.main.smallAvatarSize, fallback: .favicon)
            }
            
            Text(link.host)
                .foregroundStyle(.themedSecondary)
        }
        .font(.footnote)
    }
}
