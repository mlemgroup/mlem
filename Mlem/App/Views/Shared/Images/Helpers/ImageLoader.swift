//
//  ImageLoader.swift
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

@Observable
class ImageLoader {
    @ObservationIgnored @Setting(\.autoBypassImageProxy) var bypassImageProxy
    
    private(set) var url: URL?
    private var proxyBypass: URL?
    private(set) var uiImage: UIImage?
    private(set) var avAsset: AVAsset?
    private(set) var isVideo: Bool
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
            if url.proxyAwarePathExtension == "mp4" {
                self.loading = .loading
                self.isVideo = true
                Task(priority: .background) {
                    if let container = ImagePipeline.shared.cache.cachedImage(for: .init(url: url)) {
                        if container.type?.isVideo ?? false {
                            parseVideo(container: container)
                        }
                    }
                }
            } else {
                if let container = ImagePipeline.shared.cache.cachedImage(for: .init(url: url)) {
                    self.uiImage = resizeImage(image: container.image, maxSize: maxSize)
                    self.loading = .done
                    self.isVideo = false
                    return
                }
            }
            
//            if let container = ImagePipeline.shared.cache.cachedImage(for: .init(url: url)) {
//                if container.type?.isVideo ?? false {
//                    self.loading = .loading
//                    self.isVideo = true
//                    Task(priority: .background) {
//                        parseVideo(container: container)
//                    }
//                } else {
//                    self.uiImage = resizeImage(image: container.image, maxSize: maxSize)
//                    self.loading = .done
//                    self.isVideo = false
//                    return
//                }
//            }
        }

        self.isVideo = false
        self.uiImage = nil
        self.loading = url == nil ? .failed : .loading
    }
    
    func load() async {
        guard let url, loading == .loading else { return }
        do {
            let imageTask = ImagePipeline.shared.imageTask(with: url)
            imageTask.priority = .veryHigh
            
            let container = try await imageTask.response.container
            
            if container.type?.isVideo ?? false {
                Task {
                    parseVideo(container: container)
                }
            } else {
                uiImage = resizeImage(image: container.image, maxSize: maxSize)
                loading = .done
                return
            }
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
    
    func parseVideo(container: ImageContainer) {
        assert(container.type?.isVideo ?? false, "container type must be video")
        if let asset = container.userInfo[.videoAssetKey] as? AVAsset {
            avAsset = asset
            
            let assetImgGenerate = AVAssetImageGenerator(asset: asset)
            assetImgGenerate.appliesPreferredTrackTransform = true
            let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
            do {
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                uiImage = resizeImage(image: .init(cgImage: img), maxSize: maxSize)
            } catch {
                // TODO: elegantly handle
                print(error)
                uiImage = .blank
            }
        }
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
