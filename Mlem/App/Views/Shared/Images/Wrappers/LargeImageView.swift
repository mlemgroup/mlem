//
//  LargeImageView.swift
//  Mlem
//
//  Created by Sjmarf on 23/07/2024.
//

import SwiftUI

// ImageView for use in LargePost. Allows blurring NSFW.
// In future this view would also handle alt-text display,
// and anything else that can't go in thumbnail views etc.

struct LargeImageView: View {
    @Environment(NavigationLayer.self) private var navigation
    @AppStorage("safety.blurNsfw") var blurNsfw: Bool = true

    let url: URL?
    let shouldBlur: Bool
    @State var blurred: Bool = false
    
    init(url: URL?, nsfw: Bool) {
        @AppStorage("safety.blurNsfw") var blurNsfw = true
        self.url = url
        self.shouldBlur = blurNsfw ? nsfw : false
        self._blurred = .init(wrappedValue: blurNsfw ? nsfw : false)
    }
    
    @State private var loading: ImageLoadingState?

    var body: some View {
        DynamicImageView(url: url)
            .blur(radius: blurred ? 50 : 0, opaque: true)
            .clipShape(.rect(cornerRadius: AppConstants.largeItemCornerRadius))
            .overlay {
                NsfwOverlay(blurred: $blurred, shouldBlur: shouldBlur)
            }
            .animation(.easeOut(duration: 0.1), value: blurred)
            .onTapGesture {
                if blurred {
                    blurred = false
                } else if let loading, loading == .done, let url {
                    // Sheets don't cover the whole screen on iPad, so use a fullScreenCover instead
                    if UIDevice.isPad {
                        navigation.showFullScreenCover(.imageViewer(url))
                    } else {
                        navigation.openSheet(.imageViewer(url))
                    }
                }
            }
            .onPreferenceChange(ImageLoadingPreferenceKey.self, perform: { loading = $0 })
    }
}
