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
    let url: URL?
    private(set) var uiImage: UIImage?
    private(set) var loading: ImageLoadingState
    private(set) var error: Error?
    
    init(url: URL?) {
        self.url = url
        
        if let url {
            if let image = ImagePipeline.shared.cache.cachedImage(for: .init(url: url))?.image {
                self.uiImage = image
                self.loading = .done
                return
            }
            
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            let urlSize = Int(components?.queryItems?.first(where: { $0.name == "thumbnail" })?.value ?? "")
                        
            for size in PostSize.allImageSizes where size < urlSize ?? .max {
                if let image = ImagePipeline.shared.cache.cachedImage(for: .init(url: url.withIconSize(size)))?.image {
                    self.uiImage = image
                    self.loading = [image.size.width, image.size.height].contains(CGFloat(size)) ? .loading : .done
                    return
                }
            }
        }

        self.uiImage = nil
        self.loading = url == nil ? .failed : .loading
    }
    
    @Sendable
    @MainActor
    func load() async {
        guard let url, loading == .loading else { return }
        do {
            print("START")
            let imageTask = ImagePipeline.shared.imageTask(with: url)
            imageTask.priority = .veryHigh
            let image = try await imageTask.image
            uiImage = image
            loading = .done
            print("DONE")
        } catch {
            self.error = error
            loading = .failed
        }
    }
}
