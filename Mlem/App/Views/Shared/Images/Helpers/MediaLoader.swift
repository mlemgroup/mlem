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
    
    var canBypassProxy: Bool {
        switch self {
        case .proxyFailure: true
        default: false
        }
    }
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
    @ObservationIgnored @Setting(\.autoBypassImageProxy) var bypassImageProxy
    
    private(set) var url: URL?
    private var proxyBypass: URL?
    private(set) var mediaType: MediaType
    private(set) var loading: MediaLoadingState
    private(set) var error: ImageLoadingError?
    
    init(url: URL?) {
        self.url = url
        if let url,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let base = components.queryItems?.first(where: { $0.name == "url" })?.value {
            self.proxyBypass = URL(string: base)
        }
        
        if let url, let container = ImagePipeline.shared.cache.cachedImage(for: .init(url: url)) {
            self.mediaType = container.animatedMediaType
            self.loading = .done
            return
        }
        
        self.mediaType = .image(.blank)
        self.loading = url == nil ? .failed : .loading
    }
    
    func load() async {
        guard let url, loading == .loading else { return }
        do {
            let imageTask = ImagePipeline.shared.imageTask(with: url)
            imageTask.priority = .veryHigh
            
            let container = try await imageTask.response.container
            
            mediaType = container.animatedMediaType
            loading = .done
            return
        } catch {
            if let proxyBypass {
                if bypassImageProxy {
                    await bypassProxy()
                } else {
                    self.error = .proxyFailure(proxyBypass: proxyBypass)
                    loading = .proxyFailed
                }
            } else {
                self.error = .error(error: error)
                loading = .failed
            }
        }
    }
    
    @MainActor
    func bypassProxy() async {
        error = nil
        loading = .loading
        url = proxyBypass
        proxyBypass = nil
        await load()
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
                .video(still: generateAVThumbnail(asset: asset), animated: asset)
            } else {
                .image(.blank)
            }
        default:
            .image(image)
        }
    }
}

func generateAVThumbnail(asset: AVAsset) -> UIImage {
    let assetImgGenerate = AVAssetImageGenerator(asset: asset)
    assetImgGenerate.appliesPreferredTrackTransform = true
    let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
    do {
        return try .init(cgImage: assetImgGenerate.copyCGImage(at: time, actualTime: nil))
    } catch {
        print(error)
        return .blank
    }
}
