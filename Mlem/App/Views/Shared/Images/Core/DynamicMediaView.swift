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

struct DynamicMediaView: View {
    @Environment(Palette.self) var palette
    @Environment(NavigationLayer.self) var navigation
    
    @Setting(\.bypassImageProxyShown) var bypassImageProxyShown
    
    @State var loader: MediaLoader
    @State var loadingPref: MediaLoadingState?
    @State var quickLookUrl: URL?
    @State var playing: Bool
    
    let showError: Bool
    let cornerRadius: CGFloat
    let actionsEnabled: Bool
    
    init(
        url: URL?,
        maxSize: CGFloat? = nil,
        showError: Bool = true,
        cornerRadius: CGFloat = Constants.main.mediumItemCornerRadius,
        actionsEnabled: Bool = true,
        playImmediately: Bool = false
    ) {
        self.showError = showError
        self.cornerRadius = cornerRadius
        self.actionsEnabled = actionsEnabled
        self._loader = .init(wrappedValue: .init(url: url))
        self._playing = .init(wrappedValue: playImmediately ? true : false)
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
        MediaView(media: loader.mediaType, playing: $playing)
            .overlay {
                if showError, loader.error != nil {
                    errorOverlay
                } else if loader.mediaType.isAnimated {
                    if playing {
                        Color.clear.contentShape(.rect)
                            .onTapGesture {
                                playing = false
                            }
                    } else {
                        PlayButton()
                            .onTapGesture {
                                playing = true
                            }
                    }
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
            .onChange(of: loader.loading, initial: true) { loadingPref = loader.loading }
            .preference(key: MediaLoadingPreferenceKey.self, value: loadingPref)
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
