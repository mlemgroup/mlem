//
//  File.swift
//  MlemMiddleware
//
//  Created by Sjmarf on 2025-02-25.
//  

import Foundation
import Nuke

extension Post1: ImagePrefetchProviding {
    public func imageRequests(configuration config: PrefetchingConfiguration) async -> [ImageRequest] {
        var ret: [ImageRequest] = .init()
        
        // handle loops.video embedding
        if config.embedLoops {
            await parseLoopEmbeds()
        }
        
        switch type {
        case let .media(url), let .embedded(url, _):
            // media/embedded media: only load the media
            var urlRequest: URLRequest
            switch config.imageSize {
            case .unlimited:
                urlRequest = mlemUrlRequest(url: url)
            case let .limited(size):
                urlRequest = mlemUrlRequest(url: url.withIconSize(size))
            }
            ret.append(ImageRequest(urlRequest: urlRequest, priority: .high))
        case let .link(link):
            // websites: load image and favicon
            if config.fetchFavicons, let url = link.favicon {
                let urlRequest = mlemUrlRequest(url: url)
                ret.append(ImageRequest(urlRequest: urlRequest))
            }
            if let url = link.thumbnail {
                var urlRequest: URLRequest
                switch config.imageSize {
                case .unlimited:
                    urlRequest = mlemUrlRequest(url: url)
                case let .limited(size):
                    urlRequest = mlemUrlRequest(url: url.withIconSize(size))
                }
                ret.append(ImageRequest(urlRequest: urlRequest, priority: .high))
            }
        default:
            break
        }
        return ret
    }
}
