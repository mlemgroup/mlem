//
//  ImageLoader.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

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

@Observable
class ImageLoader {
    @ObservationIgnored @Setting(\.autoBypassImageProxy) var bypassImageProxy
    
    private(set) var url: URL?
    private var proxyBypass: URL?
    private(set) var uiImage: UIImage?
    private(set) var loading: ImageLoadingState
    private(set) var error: ImageLoadingError?
    private(set) var maxSize: CGFloat?
    
    init(url: URL?, maxSize: CGFloat? = nil) {
        self.url = url
        if let url,
           let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let base = components.queryItems?.first(where: { $0.name == "url" })?.value {
            self.proxyBypass = URL(string: base)
        }
        self.maxSize = maxSize
        
        if let url {
            if let image = ImagePipeline.shared.cache.cachedImage(for: .init(url: url))?.image {
                self.uiImage = resizeImage(image: image, maxSize: maxSize)
                self.loading = .done
                return
            }
                        
            if let image = ImagePipeline.shared.cache.cachedImage(
                for: .init(url: url.withIconSize(Constants.main.feedImageResolution))
            )?.image {
                self.uiImage = image
                if [image.size.width, image.size.height].contains(CGFloat(Constants.main.feedImageResolution)) {
                    self.loading = .loading
                } else {
                    self.loading = .done
                }
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
            let imageTask = ImagePipeline.shared.imageTask(with: url)
            imageTask.priority = .veryHigh
            let image = try await imageTask.image
            uiImage = resizeImage(image: image, maxSize: maxSize)
            loading = .done
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
        uiImage = nil
        loading = .loading
        url = proxyBypass
        proxyBypass = nil
        await load()
    }
}

private func resizeImage(image: UIImage, maxSize: CGFloat?) -> UIImage {
    if let maxSize, image.size.width > maxSize || image.size.height > maxSize {
        let size: CGSize
        if image.size.width > image.size.height {
            size = CGSize(width: maxSize, height: image.size.height * (maxSize / image.size.width))
        } else {
            size = CGSize(width: image.size.width * (maxSize / image.size.height), height: maxSize)
        }
        return image.resized(to: size)
    }
    return image
}
