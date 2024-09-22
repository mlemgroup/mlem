//
//  DynamicImageView.swift
//  Mlem
//
//  Created by Sjmarf on 12/06/2024.
//

import Nuke
import NukeUI
import QuickLook
import SDWebImageSwiftUI
import SwiftUI

extension UIImage {
    static let blank: UIImage = .init()
}

extension Data {
    static let blank: Data = .init()
}

struct DynamicMediaView: View {
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.openURL) private var openURL
    
    @Setting(\.bypassImageProxyShown) var bypassImageProxyShown
    
    @State var loader: any ImageLoading
    @State var loadingPref: ImageLoadingState?
    @State var quickLookUrl: URL?
    @State var isAnimating: Bool = false
    
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
        
        if url?.mediaType == .animatedImage {
            self._loader = .init(wrappedValue: AnimatedImageLoader())
        } else {
            self._loader = .init(wrappedValue: ImageLoader(url: url, maxSize: maxSize))
        }
    }
    
    var body: some View {
        if actionsEnabled, let url = loader.url {
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
    
    @ViewBuilder
    var content: some View {
        Group {
            if let url = loader.url {
                switch url.mediaType {
                case .image:
                    // Image(uiImage: loader.uiImage ?? .blank).resizable()
                    Text("Image")
                case .animatedImage:
                    Text("Howdy")
//                    if let cacheKey = SDWebImageManager.shared.cacheKey(for: loader.url) {
//                        Text("\(cacheKey)")
//                    } else {
//                        Text("Huh?")
//                    }
                    
                    // if let data = SDImage
                    
//                    AnimatedImage(url: loader.url) {
//                        ProgressView()
//                    }
//                    .resizable()
                case .video:
                    Text("Video goes here")
                // TestVideoView(url: url)
                case .unsupported:
                    Text("Placeholder")
                }
            }
        }
        .aspectRatio(loader.uiImage?.size ?? .init(width: 4, height: 3), contentMode: .fit)
        .overlay {
            if showError, loader.error != nil {
                errorOverlay
            } else if loader.loading == .loading {
                ProgressView()
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
                        .padding(2)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                }
            }
        #endif
            .clipShape(.rect(cornerRadius: cornerRadius))
            .onChange(of: loader.loading, initial: true) { loadingPref = loader.loading }
            .preference(key: ImageLoadingPreferenceKey.self, value: loadingPref)
//        .onAppear {
//            Task {
//                await loader.load()
//            }
//        }
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
                    VStack(spacing: Constants.main.standardSpacing) {
                        Image(systemName: Icons.missing)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 50)
                            .padding(4)
                            .foregroundStyle(palette.tertiary)
                        
                        if let url = loader.url {
                            Text(url.host() ?? "unknown host")
                                .font(.caption)
                                .foregroundStyle(palette.secondary)
                            
                            Button("Open in Browser") {
                                openURL(url)
                            }
                            .foregroundStyle(palette.accent)
                            .buttonStyle(.bordered)
                            .padding(.horizontal, Constants.main.standardSpacing)
                        }
                    }
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
