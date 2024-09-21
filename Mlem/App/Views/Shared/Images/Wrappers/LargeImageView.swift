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
    @Setting(\.blurNsfw) var blurNsfw

    let url: URL?
    let shouldBlur: Bool
    var onTapActions: (() -> Void)?
    @State var blurred: Bool = false
    
    init(url: URL?, shouldBlur: Bool, onTapActions: (() -> Void)? = nil) {
        self.url = url
        self.onTapActions = onTapActions
        self.shouldBlur = shouldBlur
        self._blurred = .init(wrappedValue: shouldBlur)
    }
    
    @State private var loading: ImageLoadingState?

    var body: some View {
        DynamicMediaView(url: url)
            .dynamicBlur(blurred: blurred)
            .clipShape(.rect(cornerRadius: Constants.main.mediumItemCornerRadius))
            .overlay {
                NsfwOverlay(blurred: $blurred, shouldBlur: shouldBlur)
            }
            .onChange(of: blurred, initial: false) {
                // trigger tap actions when post unblurred
                if !blurred, let onTapActions {
                    onTapActions()
                }
            }
            .animation(.easeOut(duration: 0.1), value: blurred)
            .onTapGesture {
                if let onTapActions {
                    onTapActions()
                }
                if let loading, loading == .done, let url {
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
