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
final class Post1: Post1Providing {
    var api: ApiClient
    var post1: Post1 { self }
    
    let actorId: URL
    let id: Int
    
    let created: Date
    
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
    var updated: Date?
    
    init(
        api: ApiClient,
        actorId: URL,
        id: Int,
        creationDate: Date,
        title: String = "",
        content: String? = "",
        links: [LinkType] = [],
        linkUrl: URL? = nil,
        deleted: Bool = false,
        embed: PostEmbed? = nil,
        pinnedCommunity: Bool = false,
        pinnedInstance: Bool = false,
        locked: Bool = false,
        nsfw: Bool = false,
        removed: Bool = false,
        thumbnailUrl: URL? = nil,
        updatedDate: Date? = nil
    ) {
        self.api = api
        self.actorId = actorId
        self.id = id
        self.created = creationDate
        self.title = title
        self.content = content
        self.links = links
        self.linkUrl = linkUrl
        self.deleted = deleted
        self.embed = embed
        self.pinnedCommunity = pinnedCommunity
        self.pinnedInstance = pinnedInstance
        self.locked = locked
        self.nsfw = nsfw
        self.removed = removed
        self.thumbnailUrl = thumbnailUrl
        self.updated = updatedDate
    }
}
