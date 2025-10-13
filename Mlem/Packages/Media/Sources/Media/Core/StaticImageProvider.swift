//
//  StaticImageProvider.swift
//  Media
//
//  Created by Eric Andrews on 2025-10-13.
//

import Observation
import Foundation
import SwiftUI
import Nuke

@Observable
public class StaticImageProvider {
    public enum LoadingState {
        case empty, loading, done, failed
    }
    
    public var images: [URL: UIImage]?
    public var loadingState: LoadingState = .empty
    
    public init() {}
    
    public func loadImages(for imageRequests: [ImageRequest]) {
        guard loadingState == .empty else {
            assertionFailure("Cannot call loadImages on non-empty provider")
            return
        }
        
        loadingState = .loading
        Task {
            var newImages: [URL: UIImage] = .init()
            for request in imageRequests {
                guard let url = request.url else {
                    assertionFailure("No request URL")
                    loadingState = .failed
                    break
                }
                let response = try await ImagePipeline.shared.image(for: request)
                newImages[url] = response
                print("DEBUG got \(url))")
            }
            images = newImages
            loadingState = .done
        }
    }
}
