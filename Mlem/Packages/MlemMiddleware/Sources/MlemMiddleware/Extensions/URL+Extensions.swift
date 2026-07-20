//
//  URL+Identifiable.swift
//  Mlem
//
//  Created by Nicholas Lawson on 04/06/2023.
//

import Foundation
import os

extension URL: @retroactive Identifiable {
    public var id: URL { absoluteURL }
}

public extension URL {
    static func post(host: String, id: Int) -> Self {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/post/\(id)"
        return components.url! // This will always succeed
    }
    
    static func comment(host: String, id: Int) -> Self {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/comment/\(id)"
        return components.url! // This will always succeed
    }
    
    static func community(host: String, name: String) -> Self {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/c/\(name)"
        return components.url! // This will always succeed
    }

    static func person(host: String, name: String) -> Self {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/u/\(name)"
        return components.url! // This will always succeed
    }
}

public extension URL {
    // Spec described here: https://join-lemmy.org/docs/contributors/04-api.html#images
    func withIconSize(_ size: Int?) -> URL {
        guard scheme == "http" || scheme == "https" else { return self }
        guard let size else { return self }
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            Logger.universal.warning("Failed to create URLComponents")
            return appending(queryItems: [.init(name: "thumbnail", value: String(size))])
        }
        var queryItems = components.queryItems ?? []
        queryItems.removeFirst(where: { $0.name == "thumbnail" })
        queryItems.append(.init(name: "thumbnail", value: String(size)))
        components.queryItems = queryItems
        return components.url ?? self
    }
    
    func removingPathComponents() -> URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.port = port
        return components.url!
    }
    
    private struct LoopsVideoResponse: Codable {
        let data: Body
        internal struct Body: Codable {
            let media: Media
            internal struct Media: Codable {
                let src_url: URL
            }
        }
    }
    
    /// Attempts to extract the underlying loops.video media URL from this URL
    /// - Returns: loops.video media URL if this is a loops.video url and the underlying URL was successfully parsed, nil otherwise
    func parseEmbeddedLoops() async -> URL? {
        // TODO: Pending loops.video maturation
        // - More reliable way of determining if this is a Loops server
        // - More robust way of extracting media URL (preferably API support)
        guard host() == "loops.video" else { return nil }
        
        do {
            let (websiteContent, _) = try await URLSession.shared.data(from: self)
            
            // parse video API ID from website content
            let apiIdRegex = /<meta property="og:image" content="https:\/\/loopsusercontent\.com\/videos\/\d+\/((?<apiId>\d*))\/.*\/>/
            guard let str: String = String(data: websiteContent, encoding: .utf8),
                  let match = str.firstMatch(of: apiIdRegex),
                  let apiUrl = URL(string: "https://loops.video/api/v1/video/\(match.apiId)") else {
                return nil
            }
            
            // query API for video id
            let (apiResponse, _) = try await URLSession.shared.data(from: apiUrl)
            let decodedResponse = try JSONDecoder.defaultDecoder.decode(LoopsVideoResponse.self, from: apiResponse)
            return decodedResponse.data.media.src_url
        } catch {
            Logger.universal.error("Failed to parse embedded loops: \(error.localizedDescription)")
        }
        return nil
    }

    func proxiedUrl() -> URL? {
        if let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems,
            let baseUrlString = queryItems.first(where: { $0.name == "url" })?.value,
            let baseUrl = URL(string: baseUrlString) {
            baseUrl
        } else {
            nil
        }
    }

    func unwrapProxy() -> URL {
        proxiedUrl() ?? self
    }
    
    /// Path extension of this URL, taking into account image proxy behavior
    var proxyAwarePathExtension: String? {
        var ret = pathExtension
        
        // image proxies that use url query param don't have pathExtension so we extract it from the embedded url
        if ret.isEmpty {
            ret = unwrapProxy().pathExtension
        }
        
        return ret.isEmpty ? nil : ret.lowercased()
    }
    
    var isMedia: Bool {
        if scheme == "mlempreview" { return true }
        return proxyAwarePathExtension?.isContainedIn(["jpg", "jpeg", "png", "webp", "gif", "avif", "mp4"]) ?? false
    }
    
    var isYouTubeLink: Bool {
        guard let host = host()?.lowercased() else { return false }
        return host == "youtube.com" || host == "www.youtube.com" || host == "youtu.be" || host == "m.youtube.com"
    }
    
    var youTubeVideoId: String? {
        guard isYouTubeLink else { return nil }
        
        let host = host()?.lowercased() ?? ""
        
        if host == "youtu.be" {
            let pathComponents = pathComponents
            if pathComponents.count > 1 {
                return pathComponents[1]
            }
        } else if host == "youtube.com" || host == "www.youtube.com" || host == "m.youtube.com" {
            guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
                  let queryItems = components.queryItems,
                  let videoId = queryItems.first(where: { $0.name == "v" })?.value else {
                let pathComponents = pathComponents
                if pathComponents.count > 2, pathComponents[1] == "embed" {
                    return pathComponents[2]
                }
                
                return nil
            }
            
            return videoId
        }
        
        return nil
    }
    
    var youTubeThumbnailUrl: URL? {
        guard let videoId = youTubeVideoId else { return nil }
        return URL(string: "https://img.youtube.com/vi/\(videoId)/mqdefault.jpg")
    }
}
