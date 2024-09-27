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
    
    @State var loadingPref: MediaLoadingState? // tracked separately to allow correct propagation of inital value
    
    @State var loader: FixedImageLoader
    let fallback: Fallback
    let showProgress: Bool
    let blurred: Bool
    
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
        blurred: Bool = false
    ) {
        self.fallback = fallback
        self.showProgress = showProgress
        self._loader = .init(wrappedValue: .init(url: url, size: size))
        self.blurred = blurred
    }
    
    var isMovie: Bool { loader.url?.proxyAwarePathExtension?.isMovieExtension ?? false }
    
    var body: some View {
        Color.clear
            .contentShape(.rect)
            .overlay {
                content
                    .onAppear {
                        Task(priority: .background) {
                            await loader.load()
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
        if loader.loading == .failed
            || isMovie
            || loader.loading == .proxyFailed
            || (loader.loading == .loading && !showProgress) {
            fallbackImage
                .overlay {
                    if loader.isAnimated {
                        PlayButton(postSize: postSize)
                    }
                }
        } else {
            if loader.loading == .loading {
                ProgressView().tint(.secondary)
            } else {
                Image(uiImage: loader.uiImage ?? .blank)
                    .resizable()
                    .scaledToFill()
                    .dynamicBlur(blurred: blurred)
                    .overlay {
                        if loader.isAnimated {
                            PlayButton(postSize: postSize)
                        }
                    }
            }
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
                .foregroundStyle(.white, .gray.gradient)
        case .favicon:
            Image(systemName: fallback.icon)
                .foregroundStyle(palette.secondary)
        case .image, .movie:
            let icon: String = (loader.loading == .failed || isMovie) ? fallback.icon : Icons.proxy
            Image(systemName: icon)
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(palette.secondary)
                .background(palette.thumbnailBackground)
        }
    }
}
