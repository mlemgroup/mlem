//
//  MediaLoader.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import AVFoundation
import Foundation
import MlemMiddleware
import Nuke
import Rest
import SwiftUI

// MARK: Types

public enum ImageLoadingError {
    case proxyFailure(proxyBypass: URL)
    case error(error: Error)
}

public enum MediaType {
    case image(UIImage)
    case video(still: UIImage, animated: AVAsset)
    case animated(still: UIImage, animated: Data)
    
    public var image: UIImage {
        switch self {
        case let .image(image), let .video(image, _), let .animated(image, _): image
        }
    }
    
    public var isAnimated: Bool {
        switch self {
        case .image: false
        default: true
        }
    }
}

public enum MediaLoadingState {
    case loading, done, proxyFailed, failed
}

// MARK: Core

@Observable
public class MediaLoader {
    public private(set) var url: URL?
    public private(set) var mediaType: MediaType?
    public private(set) var loading: MediaLoadingState
    public private(set) var error: ImageLoadingError?
    
    @MainActor func setUrl(_ newValue: URL?) { url = newValue }
    @MainActor func setMediaType(_ newValue: MediaType?) { mediaType = newValue }
    @MainActor func setLoading(_ newValue: MediaLoadingState) { loading = newValue }
    @MainActor func setError(_ newValue: ImageLoadingError?) { error = newValue }
    
    private let autoBypassImageProxy: Bool
    private var proxyBypass: URL?
    
    private let size: CGSize?
    private let processors: [any ImageProcessing]
    
    public init(url: URL? = nil, size: CGSize? = nil, autoBypassImageProxy: Bool) {
        self.url = url
        self.size = size
        self.autoBypassImageProxy = autoBypassImageProxy
        
        if let size {
            self.processors = [.resize(size: size)]
        } else {
            self.processors = .init()
        }
        
        self.proxyBypass = url?.proxiedUrl()
        
        if let cachedImage = retrieveCachedImage(for: url, with: processors) {
            self.mediaType = cachedImage
            self.loading = .done
            return
        }
        
        self.mediaType = nil
        self.loading = url == nil ? .failed : .loading
    }
    
    /// Loads the given url.
    public func load(_ url: URL?) async {
        // noop if url unchanged and loading done
        guard !(url == self.url && loading == .done) else {
            return
        }
        
        // reset everything
        await setUrl(url)
        await setMediaType(nil)
        await setLoading(.loading)
        await setError(nil)
        
        proxyBypass = url?.proxiedUrl()
        
        // easy case: nil url
        guard let url else {
            await setLoading(.failed)
            return
        }
        
        // handle previews
        #if DEBUG
            if url.scheme == "mlempreview" {
                await setMediaType(.image(.init(named: url.lastPathComponent)!))
                await setLoading(.done)
                return
            }
        #endif
        
        // if already in cache, take the cached value
        if let mediaType = retrieveCachedImage(for: url, with: processors) {
            await setMediaType(mediaType)
            await setLoading(.done)
            return
        }
        
        // otherwise actually load the image
        do {
            let imageTask = ImagePipeline.shared.imageTask(with: .init(
                url: url,
                processors: processors
            ))
            imageTask.priority = .veryHigh
            
            let container = try await imageTask.response.container
            
            await setMediaType(container.animatedMediaType)
            await setLoading(.done)
            return
        } catch {
            if let proxyBypass, autoBypassImageProxy {
                await load(proxyBypass)
            } else {
                if let proxyBypass {
                    await setError(.proxyFailure(proxyBypass: proxyBypass))
                    await setLoading(.proxyFailed)
                } else {
                    await setError(.error(error: error))
                    await setLoading(.failed)
                }
            }
        }
    }
}

// MARK: Helpers

func retrieveCachedImage(for url: URL?, with processors: [ImageProcessing]) -> MediaType? {
    if let url,
       let container = ImagePipeline.shared.cache.cachedImage(for: .init(
           url: url,
           processors: processors
       )) {
        return container.animatedMediaType
    }
    return nil
}

extension ImageContainer {
    var animatedMediaType: MediaType {
        switch type {
        case .gif, .webp:
            if let data {
                .animated(still: image, animated: data)
            } else {
                .image(image)
            }
        case .m4v, .mov, .mp4:
            if let asset = userInfo[.videoAssetKey] as? AVAsset {
                .video(still: image, animated: asset)
            } else {
                .image(image)
            }
        default:
            .image(image)
        }
    }
}
