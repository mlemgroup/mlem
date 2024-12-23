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
    @Environment(MediaState.self) var mediaState
    
    @Environment(NavigationLayer.self) private var navigation
    @Setting(\.blurNsfw) var blurNsfw

    let url: URL?
    let shouldBlur: Bool
    let onTapActions: (() -> Void)?
    let cornerRadius: CGFloat
    @State var blurred: Bool = false
    
    init(
        url: URL?,
        shouldBlur: Bool,
        cornerRadius: CGFloat = Constants.main.mediumItemCornerRadius,
        onTapActions: (() -> Void)? = nil
    ) {
        self.url = url
        self.onTapActions = onTapActions
        self.shouldBlur = shouldBlur
        self.cornerRadius = cornerRadius
        self._blurred = .init(wrappedValue: shouldBlur)
    }
    
    @State private var loading: MediaLoadingState?

    var body: some View {
        DynamicMediaView(url: url, cornerRadius: cornerRadius)
            .dynamicBlur(blurred: blurred)
            .clipShape(.rect(cornerRadius: cornerRadius))
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
                if loading == .done || loading == nil, let url {
                    mediaState.url = url
                }
            }
            .onPreferenceChange(MediaLoadingPreferenceKey.self, perform: {
                loading = $0
            })
    }
}
