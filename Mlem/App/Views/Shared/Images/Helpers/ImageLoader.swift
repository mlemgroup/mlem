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

enum MediaHandler {
    case nuke
    case nukeVideo(AVAsset)
    case sdWebImage(URL)
}

@Observable
class ImageLoader {
    @ObservationIgnored @Setting(\.autoBypassImageProxy) var bypassImageProxy
    
    private(set) var url: URL?
    private var proxyBypass: URL?
    private(set) var uiImage: UIImage?
    private(set) var avAsset: AVAsset?
    private(set) var gifAsset: Data?
    private(set) var webpData: Data?
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
            if url.proxyAwarePathExtension == "mp4" || url.proxyAwarePathExtension == "gif" {
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
                    if container.type == .gif {
                        self.gifAsset = container.data
                    } else if container.type == .webp {
                        self.webpData = container.data
                    }
                    self.uiImage = resizeImage(image: container.image, maxSize: maxSize)
                    self.loading = .done
                    self.isVideo = url.proxyAwarePathExtension == "gif"
                    return
                }
            }
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
                if container.type == .gif {
                    gifAsset = container.data
                } else if container.type == .webp {
                    webpData = container.data
                }
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
