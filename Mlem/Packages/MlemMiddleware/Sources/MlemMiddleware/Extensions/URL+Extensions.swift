//
//  URL+Identifiable.swift
//  Mlem
//
//  Created by Nicholas Lawson on 04/06/2023.
//

import Foundation

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
            print("Failed to create URLComponents")
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
    
    /// Attempts to extract the underlying loops.video media URL from this URL
    /// - Returns: loops.video media URL if this is a loops.video url and the underlying URL was successfully parsed, nil otherwise
    func parseEmbeddedLoops() async -> URL? {
        // TODO: Pending loops.video maturation
        // - More reliable way of determining if this is a Loops server
        // - More robust way of extracting media URL (preferably API support)
        guard host() == "loops.video" else { return nil }
        
        do {
            let urlRegex = /video-src="(?<url>.*)"/
            let request: URLRequest = .init(url: self)
            let (websiteContent, _) = try await URLSession.shared.data(for: request)
            
            if let str = String(data: websiteContent, encoding: .utf8),
               let match = str.firstMatch(of: urlRegex),
               let loopUrl: URL = .init(string: .init(match.url)) {
                return loopUrl
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    /// Path extension of this URL, taking into account image proxy behavior
    var proxyAwarePathExtension: String? {
        var ret = pathExtension
        
        // image proxies that use url query param don't have pathExtension so we extract it from the embedded url
        if ret.isEmpty,
           let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems,
           let baseUrlString = queryItems.first(where: { $0.name == "url" })?.value,
           let baseUrl = URL(string: baseUrlString) {
            ret = baseUrl.pathExtension
        }
        
        return ret.isEmpty ? nil : ret.lowercased()
    }
    
    var isMedia: Bool {
        if scheme == "mlempreview" { return true }
        return proxyAwarePathExtension?.isContainedIn(["jpg", "jpeg", "png", "webp", "gif", "mp4"]) ?? false
    }
}
