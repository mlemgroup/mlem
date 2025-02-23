//
//  FixedImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-01.
//

import Foundation
import MlemMiddleware
import Nuke
import SwiftUI

/// Image view that always has a fixed size. The image will be scaled to the given size, but resized to fill its parent frame.
struct FixedImageView: View {
    @Environment(Palette.self) var palette
    
    @Setting(\.postSize) var postSize
    
    @State var loadingPref: MediaLoadingState? // tracked separately to allow correct propagation of initial value
    
    @State var loader: FixedImageLoader
    
    let url: URL?
    let fallback: Fallback
    let showProgress: Bool
    let blurred: Bool
    let showPlayButton: Bool
    
    /// Enumeration of placeholder images to use if image loading fails
    enum Fallback {
        case person, community, instance, favicon, image, movie
        
        var icon: String {
            switch self {
            case .person: Icons.personCircleFill
            case .community: Icons.communityCircleFill
            case .instance: Icons.instanceCircleFill
            case .favicon: Icons.browser
            case .image: Icons.missing
            case .movie: "film"
            }
        }
    }
    
    init(
        url: URL?,
        size: CGSize,
        fallback: Fallback,
        showProgress: Bool,
        blurred: Bool = false,
        showPlayButton: Bool = true
    ) {
        self.fallback = fallback
        self.showProgress = showProgress
        self.url = url
        self.blurred = blurred
        self.showPlayButton = showPlayButton
        self._loader = .init(wrappedValue: .init(size: size))
    }
    
    var body: some View {
        Color.clear
            .task(id: url) {
                await loader.load(url)
            }
            .contentShape(.rect)
            .overlay {
                content
                    .overlay {
                        if loader.isAnimated, showPlayButton {
                            PlayButton(postSize: postSize)
                        }
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .onChange(of: loader.loading, initial: true) { loadingPref = loader.loading }
                    .preference(key: MediaLoadingPreferenceKey.self, value: loadingPref)
                    .allowsHitTesting(false)
            }
    }
    
    @ViewBuilder
    var content: some View {
        if let uiImage = loader.uiImage {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .dynamicBlur(blurred: blurred)
        } else if showProgress, loader.loading == .loading {
            ProgressView().tint(.secondary)
        } else {
            fallbackImage
        }
    }
    
    @ViewBuilder
    var fallbackImage: some View {
        switch fallback {
        case .person, .community, .instance:
            Image(systemName: fallback.icon)
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.palette)
                .foregroundStyle(palette.selectedInteractionBarItem, palette.neutralAccent.gradient)
        case .favicon:
            Image(systemName: fallback.icon)
                .foregroundStyle(palette.secondary)
        case .image, .movie:
            let icon: String = loader.loading == .proxyFailed ? Icons.proxy : fallback.icon
            Image(systemName: icon)
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(palette.secondary)
                .background(palette.thumbnailBackground)
        }
    }
}
