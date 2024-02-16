//
//  Post1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

protocol Post1Providing: PostStubProviding {
    var post1: Post1 { get }
    
    var id: Int { get }
    var title: String { get }
    var content: String? { get }
    var deleted: Bool { get }
    var embed: PostEmbed? { get }
    var pinnedCommunity: Bool { get }
    var pinnedInstance: Bool { get }
    var locked: Bool { get }
    var nsfw: Bool { get }
    var creationDate: Date { get }
    var removed: Bool { get }
    var thumbnailUrl: URL? { get }
    var updatedDate: Date? { get }
}

typealias Post = Post1Providing

extension Post1Providing {
    var actorId: URL { post1.actorId }
    var id: Int { post1.id }
    var title: String { post1.title }
    var content: String? { post1.content }
    var deleted: Bool { post1.deleted }
    var embed: PostEmbed? { post1.embed }
    var pinnedCommunity: Bool { post1.pinnedCommunity }
    var pinnedInstance: Bool { post1.pinnedInstance }
    var locked: Bool { post1.locked }
    var nsfw: Bool { post1.nsfw }
    var creationDate: Date { post1.creationDate }
    var removed: Bool { post1.removed }
    var thumbnailUrl: URL? { post1.thumbnailUrl }
    var updatedDate: Date? { post1.updatedDate }
}
