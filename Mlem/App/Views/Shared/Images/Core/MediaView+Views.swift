//
//  MediaView+Views.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import SwiftUI

extension MediaView {
    
    /// Struct to actually render the media. This is declared as its own struct to prevent state updates from the parent view
    /// causing unwanted behavior.
    private struct InternalMediaView: View {
        
        let media: MediaType
        let playing: Bool
        let blurred: Bool
        let aspectRatio: CGSize
        let contentMode: ContentMode
        
        var uiImage: UIImage { media.image }
        
        var body: some View {
            if media.isAnimated {
                image
                    .overlay {
                        // overlay to prevent visual hitch when swapping views and to implicitly preserve frame/cropping
                        if playing {
                            animatedContent
                                .background {
                                    if !blurred {
                                        ProgressView()
                                    }
                                }
                        }
                    }
            } else {
                image
            }
        }

        @ViewBuilder
        var image: some View {
            if contentMode == .fit {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else if contentMode == .fill {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    // trick adapted from https://alejandromp.com/development/blog/image-aspectratio-without-frames/
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity
                    )
                    .aspectRatio(aspectRatio, contentMode: .fill)
                    .clipped()
            }
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
        InternalMediaView(
            media: loader.mediaType,
            playing: playing,
            blurred: blurred,
            aspectRatio: uiImage.verticallyBoundedAspectRatio(bounds: aspectRatio),
            contentMode: contentMode)
    }
    
    @ViewBuilder
    var nsfwOverlay: some View {
        if enableNsfwBlur {
            NsfwOverlay(blurred: $blurred)
        }
    }
    
    @ViewBuilder
    var animationControlOverlay: some View {
        if loader.mediaType.isAnimated, !blurred, !playing {
            PlayButton(postSize: .large)
                .onTapGesture {
                    playing = true
                }
        }
    }
    
    @ViewBuilder
    var errorOverlay: some View {
        if let loaderError = loader.error {
            palette.secondaryBackground.overlay {
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
                                        await loader.bypassProxy()
                                    }
                                })
                            } else {
                                Task {
                                    await loader.bypassProxy()
                                }
                            }
                        }
                        .foregroundStyle(palette.accent)
                        .buttonStyle(.bordered)
                        .padding(.horizontal, Constants.main.standardSpacing)
                    }
                    .foregroundStyle(palette.tertiary)
                case .error:
                    Image(systemName: Icons.missing)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 50)
                        .padding(4)
                        .foregroundStyle(palette.tertiary)
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
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
    }
    
    @ViewBuilder
    func contextMenuContent(url: URL) -> some View {
        Button("Save Image", systemImage: Icons.import) {
            Task { await saveImage(url: url) }
        }
        Button("Share Image", systemImage: Icons.share) {
            Task { await shareImage(url: url) }
        }
        Button("Quick Look", systemImage: Icons.imageDetails) {
            Task { await showQuickLook(url: url) }
        }
    }
}
