//
//  FixedImageLoader.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-09-01.
//

import Foundation
import Nuke
import SwiftUI

@Observable
class FixedImageLoader {
    let url: URL?
    private(set) var uiImage: UIImage?
    private(set) var loading: ImageLoadingState
    private(set) var error: Error?
    private(set) var size: CGSize
    
    init(url: URL?, size: CGSize) {
        self.url = url
        self.size = size
        
        if let url {
            if let image = ImagePipeline.shared.cache.cachedImage(for: .init(
                url: url,
                processors: [.resize(size: size, crop: true)]
            ))?.image {
                self.uiImage = image
                self.loading = .done
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
            let imageTask = ImagePipeline.shared.imageTask(with: .init(
                url: url,
                processors: [.resize(size: size, contentMode: .aspectFit)]
            ))
            imageTask.priority = .veryHigh
            uiImage = try await imageTask.image
            loading = .done
        } catch {
            self.error = error
            loading = .failed
        }
    }
}
