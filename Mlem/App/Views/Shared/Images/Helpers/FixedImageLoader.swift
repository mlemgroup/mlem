//
//  FixedImageLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-01.
//

import AVFoundation
import Foundation
import MlemMiddleware
import Nuke
import SwiftUI

@Observable
class FixedImageLoader {
    @ObservationIgnored @Setting(\.autoBypassImageProxy) var autoBypassImageProxy
    
    private var proxyBypass: URL?
    private(set) var uiImage: UIImage?
    private(set) var isAnimated: Bool = false
    private(set) var loading: MediaLoadingState = .loading // start in .loading state to avoid flickering fallback image
    private(set) var error: Error?
    
    private let processors: [any ImageProcessing]
    
    init(size: CGSize) {
        self.processors = [.resize(size: size, crop: true)]
    }
    
    func load(_ url: URL?) async {
        // reset everything
        loading = .loading
        proxyBypass = nil
        uiImage = nil
        isAnimated = false
        error = nil
        
        // easy case: nil url
        guard let url else {
            loading = .done
            return
        }
        
        // parse proxy bypass
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let base = components.queryItems?.first(where: { $0.name == "url" })?.value {
            proxyBypass = URL(string: base)
        }
        
        // if movie type, can't get a valid uiImage so abort early
        if url.proxyAwarePathExtension?.isMovieExtension ?? false {
            isAnimated = true
            loading = .done
            return
        }
        
        // handle previews
        #if DEBUG
            if url.scheme == "mlempreview" {
                uiImage = .init(named: url.lastPathComponent)
                loading = .done
                return
            }
        #endif
        
        // if already in cache, just take the cached value
        if let container = ImagePipeline.shared.cache.cachedImage(for: .init(url: url, processors: processors)) {
            isAnimated = container.animatedMediaType.isAnimated
            uiImage = container.image
            loading = .done
            return
        }
        
        // otherwise actually load the image
        do {
            if !(url.proxyAwarePathExtension?.isMovieExtension ?? false) {
                let urlRequest = mlemUrlRequest(url: url)
                let imageTask = ImagePipeline.shared.imageTask(with: .init(urlRequest: urlRequest, processors: processors))
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
}
