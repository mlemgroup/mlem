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

    var body: some View {
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
