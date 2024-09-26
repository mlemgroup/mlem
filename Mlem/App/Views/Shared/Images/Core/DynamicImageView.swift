//
//  DynamicImageView.swift
//  Mlem
//
//  Created by Sjmarf on 12/06/2024.
//

import AVFoundation
import Nuke
import QuickLook
import SDWebImageSwiftUI
import SwiftUI

extension UIImage {
    static let blank: UIImage = .init()
}

struct DynamicImageView: View {
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    
    @Setting(\.bypassImageProxyShown) var bypassImageProxyShown
    
    @State var loader: ImageLoader
    @State var loadingPref: ImageLoadingState?
    @State var quickLookUrl: URL?
    @State var shouldPlayVideo: Bool = false
    
    let showError: Bool
    let cornerRadius: CGFloat
    let actionsEnabled: Bool
    
    init(
        url: URL?,
        maxSize: CGFloat? = nil,
        showError: Bool = true,
        cornerRadius: CGFloat = Constants.main.mediumItemCornerRadius,
        actionsEnabled: Bool = true
    ) {
        self.showError = showError
        self.cornerRadius = cornerRadius
        self.actionsEnabled = actionsEnabled
        self._loader = .init(wrappedValue: .init(url: url, maxSize: maxSize))
    }
    
    var body: some View {
        if actionsEnabled, let url = fullSizeUrl(url: loader.url) {
            content
                .contextMenu {
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
                .quickLookPreview($quickLookUrl)
        } else {
            content
        }
    }
    
    var content: some View {
        media
            .overlay {
                if showError, loader.error != nil {
                    errorOverlay
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .onChange(of: loader.loading, initial: true) { loadingPref = loader.loading }
            .preference(key: ImageLoadingPreferenceKey.self, value: loadingPref)
            .onAppear {
                Task {
                    await loader.load()
                }
            }
        #if DEBUG
            .overlay {
                if let ext = loader.url?.proxyAwarePathExtension?.uppercased() {
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
        #endif
    }
    
    @ViewBuilder
    var media: some View {
        if let videoAsset = loader.avAsset {
            // for performance, only render the image in feed and replace with VideoView on demand
            Image(uiImage: loader.uiImage ?? .blank)
                .resizable()
                .aspectRatio(loader.uiImage?.size ?? .init(width: 4, height: 3), contentMode: .fit)
                .onTapGesture {
                    shouldPlayVideo = true
                }
                .overlay {
                    // overlay to prevent visual hitch when swapping views and to implicitly preserve frame/cropping
                    // TODO: tap should play/pause
                    if shouldPlayVideo {
                        VideoView(asset: videoAsset)
                            .background(ProgressView())
                            .onTapGesture {
                                shouldPlayVideo = false
                            }
                    }
                }
        } else if let url = loader.url, url.proxyAwarePathExtension == "gif" {
            if let gifData = loader.gifAsset {
                NukeGifView(data: gifData)
                    .aspectRatio(loader.uiImage?.size ?? .init(width: 4, height: 3), contentMode: .fit)
            } else {
                Text("No gif data!")
            }
        } else if let url = loader.url, url.proxyAwarePathExtension == "webp", let webpData = loader.webpData {
            // for performance, only render the image in feed and replace with VideoView on demand
            Image(uiImage: loader.uiImage ?? .blank)
                .resizable()
                .aspectRatio(loader.uiImage?.size ?? .init(width: 4, height: 3), contentMode: .fit)
                .onTapGesture {
                    shouldPlayVideo = true
                }
                .overlay {
                    // overlay to prevent visual hitch when swapping views and to implicitly preserve frame/cropping
                    // TODO: tap should play/pause
                    if shouldPlayVideo {
                        AnimatedImage(data: webpData)
                            .resizable()
                            .aspectRatio(loader.uiImage?.size ?? .init(width: 4, height: 3), contentMode: .fit)
                            .onTapGesture {
                                shouldPlayVideo = false
                            }
                    }
                }
        } else {
            Image(uiImage: loader.uiImage ?? .blank)
                .resizable()
                .aspectRatio(loader.uiImage?.size ?? .init(width: 4, height: 3), contentMode: .fit)
        }
    }
    
    @ViewBuilder
    var errorOverlay: some View {
        palette.secondaryBackground.overlay {
            if let loaderError = loader.error {
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
    
    func shareImage(url: URL) async {
        if let fileUrl = await downloadImageToFileSystem(url: url, fileName: "image") {
            navigation.shareUrl = fileUrl
        }
    }
    
    func showQuickLook(url: URL) async {
        if let fileUrl = await downloadImageToFileSystem(url: url, fileName: "quicklook") {
            quickLookUrl = fileUrl
        }
    }
}
