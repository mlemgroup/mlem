//
//  MediaView+Views.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import SwiftUI

extension MediaView {
    /// Struct to actually render the media.
    /// This is declared as its own struct to prevent state updates from the parent view causing unwanted behavior.
    private struct InternalMediaView: View {
        @Environment(MediaControlState.self) var controlState
        
        let media: MediaType
        let aspectRatio: CGSize
        let contentMode: ContentMode
        
        var uiImage: UIImage { media.image }

        var body: some View {
            // WARNING: the combination of .aspectRatio and .frame modifiers in this view is very precise and
            // breaks easily. If you have to modify it, be sure to thoroughly regression test!
            // More info here: https://alejandromp.com/development/blog/image-aspectratio-without-frames/
            Group {
                if contentMode == .fit {
                    content
                } else if contentMode == .fill {
                    content
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity
                        )
                }
            }
            .aspectRatio(aspectRatio, contentMode: .fit)
        }
        
        @ViewBuilder
        var content: some View {
            if controlState.enableAnimation, media.isAnimated {
                animatedContent
            } else {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            }
        }
        
        @ViewBuilder
        var animatedContent: some View {
            Group {
                switch media {
                case let .video(_, animated):
                    VideoView(asset: animated)
                case let .gif(_, animated):
                    GifView(data: animated)
                case let .webp(_, animated):
                    WebpView(data: animated)
                default:
                    EmptyView()
                }
            }
            .aspectRatio(uiImage.size, contentMode: contentMode)
        }
    }
    
    @ViewBuilder
    var image: some View {
        InternalMediaView(
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
        } else {
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
        let fallback: Fallback = loader.loading == .proxyFailed ? .proxyFailure : fallback
        GeometryReader { geo in
            Image(systemName: fallback.icon)
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width * fallback.scaleFactor)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
    
    @ViewBuilder
    var nsfwOverlay: some View {
        if loader.loading == .done, controlState.enableNsfwOverlay {
            NsfwOverlay()
        }
    }
    
    @ViewBuilder
    var errorOverlay: some View {
        if controlState.enableErrorOverlay,
           let loaderError = loader.error,
           let navigation {
            palette.groupedBackground.tertiary.overlay {
                switch loaderError {
                case let .proxyFailure(proxyBypass):
                    VStack(spacing: Constants.main.standardSpacing) {
                        Image(systemName: Icons.proxy)
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
                    Image(systemName: Icons.missing)
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
        if developerMode, controlState.enableControlOverlay, let ext = loader.url?.proxyAwarePathExtension?.uppercased() {
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
            Button("Save", systemImage: Icons.import) {
                Task { await saveMedia(url: url) }
            }
            if let navigation {
                Button("Share...", systemImage: Icons.share) {
                    Task { await shareImage(url: url, navigation: navigation) }
                }
            }
        }
    }
}
