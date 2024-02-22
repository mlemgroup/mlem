//
//  LinkType.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-21.
//

import Foundation

/// Enumerates the types of links
/// Equatable so that things like PostModel can be equatable
/// All cases have a 'position' int for sorting the list
enum LinkType {
    // TODO: capture internal Lemmy links:
    // - users
    // - communities
    // - posts
    // - comments
    
    case website(Int, String, URL) // position, link title, url
    case user(Int, String, String, URL) // position, username, instance, url
    case community(Int, String, String, URL) // position, community name, instance, url
    
    var title: String {
        switch self {
        case let .website(_, title, _):
            return title
        case let .user(_, username, _, _):
            return "/u/\(username)"
        case let .community(_, community, _, _):
            return "/c/\(community)"
        }
    }
    
    var position: Int {
        switch self {
        case
            let .website(position, _, _),
            let .user(position, _, _, _),
            let .community(position, _, _, _):
            return position
        }
    }
    
    var url: URL {
        switch self {
        case
            let .website(_, _, url),
            let .user(_, _, _, url),
            let .community(_, _, _, url):
            return url
        }
    }
}

extension LinkType: Hashable, Identifiable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .website(position, title, url):
            hasher.combine(0)
            hasher.combine(position)
            hasher.combine(title)
            hasher.combine(url)
        case let .user(position, _, _, url):
            hasher.combine(1)
            hasher.combine(position)
            hasher.combine(url)
        case let .community(position, _, _, url):
            hasher.combine(2)
            hasher.combine(position)
            hasher.combine(url)
        }
    }
    
    var id: Int { hashValue }
    
    var isWebsite: Bool {
        if case .website = self {
            return true
        }
        return false
    }
}
