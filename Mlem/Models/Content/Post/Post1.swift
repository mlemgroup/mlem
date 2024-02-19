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
final class Post1: Post1Providing, NewContentModel {
    typealias APIType = APIPost
    var post1: Post1 { self }
    
    var source: any APISource
    
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
    
    init(source: any APISource, from post: APIPost) {
        self.source = source
        self.actorId = post.actorId
        self.id = post.id
        self.creationDate = post.published
        
        update(with: post)
    }
    
    func update(with post: APIPost) {
        updatedDate = post.updated
    
        title = post.name
        
        // We can't name this 'body' because @Observable uses that property name already
        content = post.body
        links = post.body?.parseLinks() ?? []
        
        linkUrl = post.linkUrl
        
        deleted = post.deleted
        
        if post.embed_title != nil || post.embed_description != nil || post.embed_video_url != nil {
            embed = .init(
                title: post.embed_title,
                description: post.embed_description,
                videoUrl: post.embed_video_url
            )
        }
        
        pinnedCommunity = post.featured_community
        pinnedInstance = post.featured_local
        locked = post.locked
        nsfw = post.nsfw
        removed = post.removed
        thumbnailUrl = post.thumbnailImageUrl
    }
}
