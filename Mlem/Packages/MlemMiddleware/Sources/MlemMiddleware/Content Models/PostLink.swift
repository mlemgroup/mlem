//
//  PostLink.swift
//
//
//  Created by Eric Andrews on 2024-07-30.
//

import Foundation

public struct PostLink: Hashable {
    public let content: URL
    public let thumbnail: URL?
    public let label: String
    
    public var favicon: URL? {
        if let baseUrl = content.host {
            return URL(string: "https://www.google.com/s2/favicons?sz=64&domain=\(baseUrl)")
        }
        return nil
    }

    public var host: String {
        if var host = content.host() {
            host.trimPrefix("www.")
            return host
        }
        return "website"
    }
    
    public var effectiveThumbnail: URL? {
        thumbnail ?? content.youTubeThumbnailUrl
    }
    
    public init(content: URL, thumbnail: URL?, label: String) {
        self.content = content
        self.thumbnail = thumbnail
        self.label = label
    }
}
