//
//  PostType.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-06-14.
//

import Foundation

public enum PostType: Equatable {
    /// Post containing both a title and text
    case text(String)
    /// Post containing only media
    case media(URL)
    /// Link post with embedded media content
    case embedded(URL, originalLink: URL)
    /// Link post
    case link(PostLink)
    /// Post containing only a title
    case titleOnly
    
    public var isText: Bool {
        if case .text = self {
            return true
        }
        return false
    }
    
    public var isMedia: Bool {
        switch self {
        case .media, .embedded: return true
        default: return false
        }
    }
    
    public var isLink: Bool {
        if case .link = self {
            return true
        }
        return false
    }
}
