//
//  FixedImageView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-07-31.
//

import Foundation
import MlemMiddleware
import Nuke
import SwiftUI

/// Image view that always has a 1:1 aspect ratio. Inherits sizing from parent frame.
struct FixedImageView: View {
    @Environment(Palette.self) var palette
    
    @State var loadingPref: ImageLoadingState? // tracked separately to allow correct propagation of inital value
    
    @State var loader: ImageLoader
    let fallback: Fallback
    let showProgress: Bool
    
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
        maxSize: CGFloat? = nil,
        fallback: Fallback,
        showProgress: Bool
    ) {
        self.fallback = fallback
        self.showProgress = showProgress
        self._loader = .init(wrappedValue: .init(url: url, maxSize: maxSize))
    }
    
    var body: some View {
        Color.clear
            .contentShape(.rect)
            .overlay {
                content
                    .task(loader.load)
                    .aspectRatio(1, contentMode: .fill)
                    .onChange(of: loader.loading, initial: true) { loadingPref = loader.loading }
                    .preference(key: ImageLoadingPreferenceKey.self, value: loadingPref)
                    .allowsHitTesting(false)
            }
    }
    
    @ViewBuilder
    var content: some View {
        if loader.loading == .failed || (loader.loading == .loading && !showProgress) {
            fallbackImage
        } else {
            if loader.loading == .loading {
                ProgressView().tint(.secondary)
            } else {
                Image(uiImage: loader.uiImage ?? .blank)
                    .resizable()
                    .scaledToFill()
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
            Image(systemName: fallback.icon)
                .font(.title)
                .foregroundStyle(palette.secondary)
                .background(palette.thumbnailBackground)
        }
    }
}
