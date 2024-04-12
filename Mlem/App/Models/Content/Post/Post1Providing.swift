//
//  Post1Providing.swift
//  Mlem
//
//  Created by Sjmarf on 16/02/2024.
//

import Foundation

protocol Post1Providing: PostStubProviding,
                         Interactable1Providing,
                         Actionable,
                         FeedLoadable,
                         Identifiable {
    var post1: Post1 { get }
    
    var id: Int { get }
    var title: String { get }
    var content: String? { get }
    var links: [LinkType] { get }
    var linkUrl: URL? { get }
    var deleted: Bool { get }
    var embed: PostEmbed? { get }
    var pinnedCommunity: Bool { get }
    var pinnedInstance: Bool { get }
    var locked: Bool { get }
    var nsfw: Bool { get }
    var created: Date { get }
    var removed: Bool { get }
    var thumbnailUrl: URL? { get }
    var updated: Date? { get }
}

extension Post1Providing {
    var uid: ContentModelIdentifier { .init(contentType: .post, contentId: id) }
    func sortVal(sortType: FeedLoaderSortType) -> FeedLoaderSortVal {
        switch sortType {
        case .published:
            return .published(created)
        }
    }
}

typealias Post = Post1Providing

extension Post1Providing {
    var actorId: URL { post1.actorId }
    
    var id: Int { post1.id }
    var title: String { post1.title }
    var content: String? { post1.content }
    var links: [LinkType] { post1.links }
    var linkUrl: URL? { post1.linkUrl }
    var deleted: Bool { post1.deleted }
    var embed: PostEmbed? { post1.embed }
    var pinnedCommunity: Bool { post1.pinnedCommunity }
    var pinnedInstance: Bool { post1.pinnedInstance }
    var locked: Bool { post1.locked }
    var nsfw: Bool { post1.nsfw }
    var created: Date { post1.created }
    var removed: Bool { post1.removed }
    var thumbnailUrl: URL? { post1.thumbnailUrl }
    var updated: Date? { post1.updated }
    
    var id_: Int? { post1.id }
    var title_: String? { post1.title }
    var content_: String? { post1.content }
    var links_: [LinkType]? { post1.links }
    var linkUrl_: URL? { post1.linkUrl }
    var deleted_: Bool? { post1.deleted }
    var embed_: PostEmbed? { post1.embed }
    var pinnedCommunity_: Bool? { post1.pinnedCommunity }
    var pinnedInstance_: Bool? { post1.pinnedInstance }
    var locked_: Bool? { post1.locked }
    var nsfw_: Bool? { post1.nsfw }
    var creationDate_: Date? { post1.created }
    var removed_: Bool? { post1.removed }
    var thumbnailUrl_: URL? { post1.thumbnailUrl }
    var updatedDate_: Date? { post1.updated }
}

extension Post1Providing {
    var postType: PostType {
        // post with URL: either image or link
        if let linkUrl {
            // if image, return image link, otherwise return thumbnail
            return linkUrl.isImage ? .image(linkUrl) : .link(thumbnailUrl)
        }

        // otherwise text, but post.body needs to be present, even if it's an empty string
        if let postBody = content {
            return .text(postBody)
        }

        return .titleOnly
    }
    
    var menuActions: ActionGroup {
        ActionGroup(children: [
            ActionGroup(
                children: [upvoteAction, downvoteAction]
            ),
            saveAction
        ])
    }
}
