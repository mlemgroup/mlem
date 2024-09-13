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
    
    @State var loader: ImageLoader
    @State var loadingPref: ImageLoadingState?
    @State var quickLookUrl: URL?
    
    let showError: Bool
    let cornerRadius: CGFloat
    let actionsEnabled: Bool
    
    var proxyBypass: URL? {
        if let url = loader.url,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let base = components.queryItems?.first { $0.name == "url" }?.value {
            print("proxied! base: \(base)")
            return URL(string: base)
        }
        return nil
    }
    
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
            .background {
                if showError {
                    palette.secondaryBackground
                        .overlay {
                            if loader.error != nil {
                                if let proxyBypass {
                                    Image(systemName: "firewall")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(maxWidth: 50)
                                        .padding(4)
                                        .foregroundStyle(palette.tertiary)
                                } else {
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
            }
            .onTapGesture {
                if loader.error != nil, let proxyBypass {
                    print("DEBUG tapped")
                    Task {
                        print("DEBUG calling reload with \(proxyBypass.absoluteString)")
                        await loader.reload(with: proxyBypass)
                    }
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
