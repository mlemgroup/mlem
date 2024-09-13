//
//  ImageLoader.swift
//  Mlem
//
//  Created by Sjmarf on 10/08/2024.
//

import Foundation
import Nuke
import SwiftUI

@Observable
class ImageLoader {
    var url: URL?
    private(set) var uiImage: UIImage?
    private(set) var loading: ImageLoadingState
    private(set) var error: Error?
    private(set) var maxSize: CGFloat?
    
    init(url: URL?, maxSize: CGFloat? = nil) {
        self.url = url
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
            print("DEBUG loading \(url.absoluteString)")
            let imageTask = ImagePipeline.shared.imageTask(with: url)
            imageTask.priority = .veryHigh
            let image = try await imageTask.image
            uiImage = resizeImage(image: image, maxSize: maxSize)
            loading = .done
        } catch {
            self.error = error
            print(error)
            loading = .failed
        }
    }
    
    @MainActor
    func reload(with url: URL) async {
        print("DEBUG reloading with \(url.absoluteString)")
        error = nil
        uiImage = nil
        loading = .loading
        self.url = url
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
