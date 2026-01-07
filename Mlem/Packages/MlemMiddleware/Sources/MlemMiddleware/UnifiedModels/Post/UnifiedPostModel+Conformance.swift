//
//  UnifiedPostModel+Conformance.swift
//  MlemMiddleware
//
//  Created by Eric Andrews on 2026-01-07.
//

import Foundation
import Nuke
import Rest

// MARK: CacheIdentifiable

public extension UnifiedPostModel {
    var cacheId: Int { id }
}

// MARK: ContentModel

public extension UnifiedPostModel {
    static var tierNumber: Int =  4
}

// MARK: FeedLoadable

public extension UnifiedPostModel {
    typealias FilterType = PostFilterType
    
    static func == (lhs: UnifiedPostModel, rhs: UnifiedPostModel) -> Bool {
        lhs.actorId == rhs.actorId
    }
    
    func sortVal(sortType: FeedLoaderSort.SortType) -> FeedLoaderSort {
        switch sortType {
        case .new:
            return .new(created)
        }
    }
}

// MARK: ImagePrefetchProviding

extension UnifiedPostModel: ImagePrefetchProviding {
    var type: PostType {
        // post with URL: image, embedded, or link
        if let linkUrl {
            // TODO: NOW
//            if let embeddedMediaUrl {
//                return .embedded(embeddedMediaUrl, originalLink: linkUrl)
//            }
            
            // if image, return image link, otherwise return thumbnail
            if linkUrl.isMedia {
                return .media(linkUrl)
            }
            return .link(.init(content: linkUrl, thumbnail: thumbnailUrl, label: embed?.title ?? title))
        }

        // otherwise text, but post.body needs to be present, even if it's an empty string
        if let postBody = content {
            return .text(postBody)
        }

        return .titleOnly
    }
    
    func parseLoopEmbeds() async {
        // TODO: NOW not noop
//        if let loopsUrl = await linkUrl.value_??.parseEmbeddedLoops() {
//            _ = await Task { @MainActor in
//                properties.embeddedMediaUrl = loopsUrl
//            }.result
//        }
    }
    
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
        // preload user and community avatars--fetching both because we don't know which we'll need, but these are super tiny
        // so it's probably not an API crime, right?
        if let avatarSize = config.avatarSize {
            if let communityAvatarLink = community.value_?.avatar {
                ret.append(ImageRequest(urlRequest: mlemUrlRequest(url: communityAvatarLink.withIconSize(avatarSize))))
            }
            
            if let userAvatarLink = creator.value_?.avatar {
                ret.append(ImageRequest(urlRequest: mlemUrlRequest(url: userAvatarLink.withIconSize(avatarSize))))
            }
        }
        
        return ret
    }
}

// MARK: SelectableContentProviding

public extension UnifiedPostModel {
    var selectableContent: String? { content }
}

// MARK: ContentIdentifiable

public extension UnifiedPostModel {
    static var modelTypeId: ContentType { .post }
}

// MARK: Resolvable

public extension UnifiedPostModel {
    /// Returns a `URL` that can be resolved by another `ApiClient`.
    func resolvableUrl(from instance: ContentModelUrlType) -> URL {
        switch instance {
        case .host: actorId.url
        case .provider: .post(host: api.host, id: id)
        }
    }
    
    @inlinable
    var allResolvableUrls: [URL] {
        ContentModelUrlType.allCases.map { resolvableUrl(from: $0) }
    }
}

// MARK: Sharable

public extension UnifiedPostModel {
    func url() -> URL { api.baseUrl.appending(path: "post/\(id)") }
}
