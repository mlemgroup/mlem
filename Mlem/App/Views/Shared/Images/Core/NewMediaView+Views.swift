//
//  MediaView+Views.swift
//  Mlem
//
//  Created by Eric Andrews on 2025-01-15.
//

import SwiftUI

extension MediaView {
    
    // MARK: - Core
    
    var image: some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: contentMode)
    }
    
    @ViewBuilder
    var animatedContent: some View {
        switch loader.mediaType {
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
    
    // MARK: - Helpers
    
    @ViewBuilder
    var nsfwOverlay: some View {
        if enableNsfwBlur {
            NsfwOverlay(blurred: $blurred)
        }
    }
    
    @ViewBuilder
    var animatedContentOverlay: some View {
        if loader.mediaType.isAnimated, !blurred {
            if playing {
                animatedContent
                    .aspectRatio(contentMode: .fit)
                    .background {
                        ProgressView()
                    }
            } else {
                PlayButton(postSize: .large)
                    .onTapGesture {
                        playing = true
                    }
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
