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
        @Environment(\.blurred) var blurred
        @Environment(MediaControlState.self) var controlState
        
        let media: MediaType
        let playing: Bool
        let aspectRatio: CGSize
        let contentMode: ContentMode
        
        var uiImage: UIImage { media.image }
        
        var body: some View {
            image
                .overlay {
                    if controlState.enableAnimation, media.isAnimated, playing {
                        animatedContent
                    }
                }
        }

        @ViewBuilder
        var image: some View {
            // WARNING: the combination of .aspectRatio and .frame modifiers in this view is very precise and
            // breaks easily. If you have to modify it, be sure to thoroughly regression test!
            // More info here: https://alejandromp.com/development/blog/image-aspectratio-without-frames/
            Group {
                if contentMode == .fit {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else if contentMode == .fill {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
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
        var animatedContent: some View {
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
    }
    
    @ViewBuilder
    var image: some View {
        if let media = loader.mediaType {
            InternalMediaView(
                media: media,
                playing: playing,
                aspectRatio: media.image.boundedAspectRatio(bounds: aspectRatio),
                contentMode: contentMode
            )
        } else {
            fallbackImage
                .frame(maxWidth: .infinity)
                .aspectRatio(aspectRatio.defaultSize, contentMode: .fit)
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
        if controlState.enableNsfwOverlay {
            NsfwOverlay()
        }
    }
    
    @ViewBuilder
    var animationControlOverlay: some View {
        if controlState.enableControlOverlay,
           controlState.enableAnimation,
           !controlState.blurred,
           loader.mediaType?.isAnimated ?? false,
           !playing {
            PlayButton(postSize: .large)
                .onTapGesture {
                    playing = true
                }
        }
    }
    
    @ViewBuilder
    var errorOverlay: some View {
        if controlState.enableErrorOverlay,
           let loaderError = loader.error,
           loaderError.showsErrorOverlay,
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
                    EmptyView()
                }
            }
        }
    }
    
    @ViewBuilder
    var developerOverlay: some View {
        if developerMode, let ext = loader.url?.proxyAwarePathExtension?.uppercased() {
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
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
