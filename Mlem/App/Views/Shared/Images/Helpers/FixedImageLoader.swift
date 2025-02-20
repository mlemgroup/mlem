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
    private(set) var isAnimated: Bool = false
    private(set) var loading: MediaLoadingState = .noUrl
    private(set) var error: Error?
    private(set) var size: CGSize
    
    init(size: CGSize) {
        self.size = size
    }
    
    func load(_ url: URL?) async {
        guard let url else {
            reset(with: url)
            return
        }
        
        // don't load the same url twice
        guard url != self.url else { return }
        
        preload(url)
        
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
            if autoBypassImageProxy, let proxyBypass {
                await load(proxyBypass)
            } else {
                self.error = error
                loading = proxyBypass == nil ? .failed : .proxyFailed
            }
        }
    }
    
    private func preload(_ url: URL) {
        reset(with: url)
        
        // parse proxy bypass
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let base = components.queryItems?.first(where: { $0.name == "url" })?.value {
            self.proxyBypass = URL(string: base)
        }
        
        // handle movie types
        if url.proxyAwarePathExtension?.isMovieExtension ?? false {
            self.isAnimated = true
            self.loading = .done
            return
        }
        
        // check if already in cache
        if let container = ImagePipeline.shared.cache.cachedImage(for: .init(
            url: url,
            processors: [.resize(size: size, crop: true)]
        )) {
            self.isAnimated = container.animatedMediaType.isAnimated
            self.uiImage = container.image
            self.loading = .done
            return
        }
        
#if DEBUG
        if url.scheme == "mlempreview" {
            self.uiImage = .init(named: url.lastPathComponent)
            self.loading = .done
            return
        }
#endif
        
        self.loading = .loading
    }
    
    private func reset(with url: URL?) {
        self.url = url
        self.proxyBypass = nil
        self.uiImage = nil
        self.isAnimated = false
        self.loading = .noUrl
        self.error = nil
    }
}
