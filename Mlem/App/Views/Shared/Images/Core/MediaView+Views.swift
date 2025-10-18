//
//  MediaView+Views.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import Media
import SwiftUI
import Theming

extension MediaView {
    @ViewBuilder
    var image: some View {
        CoreMediaView(
            media: loader.mediaType ?? .image(.blank),
            aspectRatio: uiImage.boundedAspectRatio(bounds: aspectRatio),
            contentMode: contentMode
        )
        .overlay {
            if loader.mediaType == nil {
                fallbackImage
            }
        }
    }
    
    @ViewBuilder
    var fallbackImage: some View {
        if loader.loading == .loading {
            ProgressView()
                .tint(.themedSecondary)
        } else if !showErrorOverlay {
            switch fallback.fallbackStyle {
            case .standard:
                coreFallbackImage
                    .foregroundStyle(.themedSecondary)
                    .background(fallback.background)
            case .avatar:
                coreFallbackImage
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.themedContrastingLabel, palette.neutralAccent.gradient)
            }
        }
    }
    
    @ViewBuilder
    var coreFallbackImage: some View {
        // Use contextual fallback icons even when proxy fails.
        let contextualFallback: Fallback = if loader.loading == .proxyFailed {
            fallback.fallbackStyle == .avatar ? fallback : .proxyFailure
        } else {
            fallback
        }
        
        GeometryReader { geo in
            Image(icon: contextualFallback.icon)
                .resizable()
                .scaledToFit()
                .symbolVariant(contextualFallback.fallbackStyle == .avatar ? .circle.fill : .none)
                .frame(width: geo.size.width * contextualFallback.scaleFactor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    var nsfwOverlay: some View {
        if loader.loading == .done, overlays.nsfw {
            NsfwOverlay()
        }
    }
    
    @ViewBuilder
    var errorOverlay: some View {
        if overlays.error,
           let loaderError = loader.error,
           let navigation {
            palette.groupedBackground.tertiary.overlay {
                switch loaderError {
                case let .proxyFailure(proxyBypass):
                    VStack(spacing: Constants.main.standardSpacing) {
                        Image(icon: .lemmy.imageProxy)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 50)
                            .padding(4)
                        
                        Text("Proxy Failure")
                            .fontWeight(.semibold)
                        
                        Button("Load directly from \(proxyBypass.host() ?? "unknown host")") {
                            if !bypassImageProxyShown {
                                bypassImageProxyShown = true
                                navigation.openSheet(.bypassImageProxyWarning {
                                    Task {
                                        await loader.load(proxyBypass)
                                    }
                                })
                            } else {
                                Task {
                                    await loader.load(proxyBypass)
                                }
                            }
                        }
                        .foregroundStyle(.themedAccent)
                        .buttonStyle(.bordered)
                        .padding(.horizontal, Constants.main.standardSpacing)
                    }
                    .foregroundStyle(.themedTertiary)
                default:
                    Image(icon: .general.missing)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 50)
                        .padding(4)
                        .foregroundStyle(.themedTertiary)
                }
            }
        }
    }
    
    @ViewBuilder
    var developerOverlay: some View {
        if developerMode,
           overlays.controls,
           let ext = loader.url?.proxyAwarePathExtension?.uppercased() {
            Text(ext)
                .font(.footnote)
                .fontWeight(.semibold)
                .padding(2)
                .padding(.horizontal, 2)
                .background {
                    Capsule()
                        .fill(.regularMaterial)
                }
                .padding(4)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }
    
    @ViewBuilder
    func contextMenuContent() -> some View {
        if let url = fullSizeUrl ?? loader.url {
            Button("Save", icon: .general.import) {
                Task { await saveMedia(url: url) }
            }
            if let navigation {
                Button("Share...", icon: .general.share) {
                    Task { await shareImage(url: url, navigation: navigation) }
                }
            }
        }
    }
}
