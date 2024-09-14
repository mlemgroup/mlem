//
//  FixedImageLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-01.
//

import Foundation
import Nuke
import SwiftUI

@Observable
class FixedImageLoader {
    @ObservationIgnored @Setting(\.autoBypassImageProxy) var autoBypassImageProxy
    
    private(set) var url: URL?
    private var proxyBypass: URL?
    private(set) var uiImage: UIImage?
    private(set) var loading: ImageLoadingState
    private(set) var error: Error?
    private(set) var size: CGSize
    
    init(url: URL?, size: CGSize) {
        self.url = url
        if let url,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let base = components.queryItems?.first(where: { $0.name == "url" })?.value {
            self.proxyBypass = URL(string: base)
        }
        self.size = size
        
        if let url {
            if let image = ImagePipeline.shared.cache.cachedImage(for: .init(
                url: url,
                processors: [.resize(size: size, crop: true)]
            ))?.image {
                self.uiImage = image
                self.loading = .done
                return
            }
        }

        self.uiImage = nil
        self.loading = url == nil ? .failed : .loading
    }
    
    @MainActor
    func load() async {
        guard let url, loading == .loading else { return }
        do {
            let imageTask = ImagePipeline.shared.imageTask(with: .init(
                url: url,
                processors: [.resize(size: size, contentMode: .aspectFit)]
            ))
            imageTask.priority = .veryHigh
            uiImage = try await imageTask.image
            loading = .done
        } catch {
            if autoBypassImageProxy, proxyBypass != nil {
                await bypassProxy()
            } else {
                self.error = error
                loading = proxyBypass == nil ? .failed : .proxyFailed
            }
        }
    }
    
    @MainActor
    func bypassProxy() async {
        error = nil
        uiImage = nil
        loading = .loading
        url = proxyBypass
        proxyBypass = nil
        await load()
    }
}
