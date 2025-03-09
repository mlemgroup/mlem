//
//  MediaLoader.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import AVFoundation
import Foundation
import Nuke
import SwiftUI

enum ImageLoadingError {
    case proxyFailure(proxyBypass: URL)
    case error(error: Error)
}

enum MediaType {
    case image(UIImage)
    case video(still: UIImage, animated: AVAsset)
    case gif(still: UIImage, animated: Data)
    case webp(still: UIImage, animated: Data)
    
    var image: UIImage {
        switch self {
        case let .image(image): image
        case let .video(still, _): still
        case let .gif(still, _): still
        case let .webp(still, _): still
        }
    }
    
    var isAnimated: Bool {
        switch self {
        case .image: false
        default: true
        }
    }
}

@Observable
class MediaLoader {
    @ObservationIgnored @Setting(\.autoBypassImageProxy) var autoBypassImageProxy
    
    private(set) var url: URL?
    private var proxyBypass: URL?
    private(set) var mediaType: MediaType?
    private(set) var loading: MediaLoadingState
    private(set) var error: ImageLoadingError?
    
    private let size: CGSize?
    private let processors: [any ImageProcessing]
    
    init(url: URL? = nil, size: CGSize? = nil) {
        self.url = url
        self.size = size
        
        if let size {
            processors = [.resize(size: size, crop: true)]
        } else {
            processors = .init()
        }

        self.proxyBypass = computeProxyBypass(for: url)
        
        if let cachedImage = retrieveCachedImage(for: url, with: processors) {
            self.mediaType = cachedImage
            loading = .done
            return
        }
        
        self.mediaType = nil
        self.loading = url == nil ? .failed : .loading
    }
    
    /// Loads the given url.
    func load(_ url: URL?) async {
        // noop if url unchanged and loading done
        guard !(url == self.url && loading == .done) else {
            return
        }
        
        // reset everything
        self.url = url
        self.proxyBypass = computeProxyBypass(for: url)
        self.mediaType = nil
        self.loading = .loading
        self.error = nil
        
        // easy case: nil url
        guard let url else {
            loading = .failed
            return
        }
        
        // handle previews
        #if DEBUG
            if url.scheme == "mlempreview" {
                mediaType = .image(.init(named: url.lastPathComponent)!)
                loading = .done
                return
            }
        #endif
        
        // if already in cache, take the cached value
        if let mediaType = retrieveCachedImage(for: url, with: processors) {
            self.mediaType = mediaType
            loading = .done
            return
        }
        
        // otherwise actually load the image
        do {
            let imageTask = ImagePipeline.shared.imageTask(with: .init(url: url, processors: processors))
            imageTask.priority = .veryHigh
            
            let container = try await imageTask.response.container
            
            mediaType = container.animatedMediaType
            loading = .done
            return
        } catch {
            if let proxyBypass, autoBypassImageProxy {
                await load(proxyBypass)
            } else {
                self.error = .error(error: error)
                loading = proxyBypass == nil ? .failed : .proxyFailed
            }
        }
    }
}

extension ImageContainer {
    var animatedMediaType: MediaType {
        switch type {
        case .gif:
            if let data {
                .gif(still: image, animated: data)
            } else {
                .image(image)
            }
        case .webp:
            if let data {
                .webp(still: image, animated: data)
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
