//
//  FixedImageLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-01.
//

import AVFoundation
import Foundation
import Nuke
import SwiftUI

@Observable
class FixedImageLoader {
    @ObservationIgnored @Setting(\.autoBypassImageProxy) var autoBypassImageProxy
    
    private(set) var url: URL?
    private var proxyBypass: URL?
    private(set) var uiImage: UIImage?
    private(set) var isAnimated: Bool
    private(set) var loading: MediaLoadingState
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
        
        if url?.proxyAwarePathExtension?.isMovieExtension ?? false {
            self.isAnimated = true
            self.uiImage = nil
            self.loading = .done
            return
        } else if let url, let container = ImagePipeline.shared.cache.cachedImage(for: .init(
            url: url,
            processors: [.resize(size: size, crop: true)]
        )) {
            self.isAnimated = container.animatedMediaType.isAnimated
            self.uiImage = container.image
            self.loading = .done
            return
        }

        self.isAnimated = false
        self.uiImage = nil
        self.loading = url == nil ? .failed : .loading
    }
    
    func load() async {
        guard let url, loading == .loading else { return }
        do {
            if !(url.proxyAwarePathExtension?.isMovieExtension ?? false) {
                let imageTask = ImagePipeline.shared.imageTask(with: .init(
                    url: url,
                    processors: [.resize(size: size, crop: true)]
                ))
                let container = try await imageTask.response.container
                isAnimated = container.animatedMediaType.isAnimated
                uiImage = container.image
                loading = .done
            }
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
