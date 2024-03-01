//
//  Post1.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import SwiftUI

struct PostEmbed {
    let title: String?
    let description: String?
    let videoUrl: URL?
}

@Observable
final class Post1: Post1Providing, ContentModel {
    typealias ApiType = ApiPost
    var post1: Post1 { self }
    
    var source: ApiClient
    
    let actorId: URL
    let id: Int
    
    let creationDate: Date
    
    var title: String = ""
    var content: String? = ""
    var links: [LinkType] = []
    var linkUrl: URL?
    var deleted: Bool = false
    var embed: PostEmbed?
    var pinnedCommunity: Bool = false
    var pinnedInstance: Bool = false
    var locked: Bool = false
    var nsfw: Bool = false
    var removed: Bool = false
    var thumbnailUrl: URL?
    var updatedDate: Date?
    
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
    
    init(source: ApiClient, from post: ApiPost) {
        self.source = source
        self.actorId = post.actorId
        self.id = post.id
        self.creationDate = post.published
        
        update(with: post)
    }
    
    func update(with post: ApiPost) {
        updatedDate = post.updated
    
        title = post.name
        
        // We can't name this 'body' because @Observable uses that property name already
        content = post.body
        links = post.body?.parseLinks() ?? []
        
        linkUrl = post.linkUrl
        
        deleted = post.deleted
        
        if post.embedTitle != nil || post.embedDescription != nil || post.embedVideoUrl != nil {
            embed = .init(
                title: post.embedTitle,
                description: post.embedDescription,
                videoUrl: post.embedVideoUrl
            )
        }
        
        pinnedCommunity = post.featuredCommunity
        pinnedInstance = post.featuredLocal
        locked = post.locked
        nsfw = post.nsfw
        removed = post.removed
        thumbnailUrl = post.thumbnailImageUrl
    }
}
