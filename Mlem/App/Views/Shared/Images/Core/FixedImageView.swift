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
    
    @State var loadingPref: ImageLoadingState? // tracked separately to allow correct propagation of inital value
    
    @State var loader: FixedImageLoader
    let fallback: Fallback
    let showProgress: Bool
    let blurred: Bool
    
    /// Enumeration of placeholder images to use if image loading fails
    enum Fallback {
        case person, community, instance, favicon, image
        
        var icon: String {
            switch self {
            case .person: Icons.personCircleFill
            case .community: Icons.communityCircleFill
            case .instance: Icons.instanceCircleFill
            case .favicon: Icons.browser
            case .image: Icons.missing
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
    
    var body: some View {
        Color.clear
            .contentShape(.rect)
            .overlay {
                content
                    .onAppear {
                        Task {
                            await loader.load()
                        }
                    }
                    .aspectRatio(1, contentMode: .fill)
                    .onChange(of: loader.loading, initial: true) { loadingPref = loader.loading }
                    .preference(key: ImageLoadingPreferenceKey.self, value: loadingPref)
                    .allowsHitTesting(false)
            }
    }
    
    @ViewBuilder
    var content: some View {
        if loader.loading == .failed || loader.loading == .proxyFailed || (loader.loading == .loading && !showProgress) {
            fallbackImage
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
                            PlayButton()
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
        case .image:
            let icon: String = loader.loading == .failed ? fallback.icon : Icons.proxy
            Image(systemName: icon)
                .font(.title)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(palette.secondary)
                .background(palette.thumbnailBackground)
        }
    }
}
