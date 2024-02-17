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
    var linkUrl: URL? = nil
    var deleted: Bool = false
    var embed: PostEmbed? = nil
    var pinnedCommunity: Bool = false
    var pinnedInstance: Bool = false
    var locked: Bool = false
    var nsfw: Bool = false
    var removed: Bool = false
    var thumbnailUrl: URL? = nil
    var updatedDate: Date? = nil
    
    init(source: any APISource, from post: APIPost) {
        self.source = source
        self.actorId = post.actorId
        self.id = post.id
        self.creationDate = post.published
        
        self.update(with: post)
    }
    
    func update(with post: APIPost) {
        self.updatedDate = post.updated
    
        self.title = post.name
        
        // We can't name this 'body' because @Observable uses that property name already
        self.content = post.body
        self.links = post.body?.parseLinks() ?? []
        
        self.linkUrl = post.linkUrl
        
        self.deleted = post.deleted
        
        if post.embedTitle != nil || post.embedDescription != nil || post.embedVideoUrl != nil {
            self.embed = .init(
                title: post.embedTitle,
                description: post.embedDescription,
                videoUrl: post.embedVideoUrl
            )
        }
        
        self.pinnedCommunity = post.featuredCommunity
        self.pinnedInstance = post.featuredLocal
        self.locked = post.locked
        self.nsfw = post.nsfw
        self.removed = post.removed
        self.thumbnailUrl = post.thumbnailImageUrl
    }
}
