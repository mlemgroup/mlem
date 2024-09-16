//
//  DynamicImageView.swift
//  Mlem
//
//  Created by Sjmarf on 12/06/2024.
//

import Nuke
import QuickLook
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
        Image(uiImage: loader.uiImage ?? .blank)
            .resizable()
            .aspectRatio(loader.uiImage?.size ?? .init(width: 4, height: 3), contentMode: .fit)
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
        print(url)
        if let fileUrl = await downloadImageToFileSystem(url: url, fileName: "image") {
            navigation.shareUrl = fileUrl
        }
    }
    
    func showQuickLook(url: URL) async {
        print("DEBUG \(url)")
        if let fileUrl = await downloadImageToFileSystem(url: url, fileName: "quicklook") {
            quickLookUrl = fileUrl
        }
    }
}
