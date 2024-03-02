//
//  CommunityTier1.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation
import SwiftUI

@Observable
final class Community1: Community1Providing, ContentModel {
    typealias ApiType = ApiCommunity
    var community1: Community1 { self }
    var source: ApiClient

    let actorId: URL
    let id: Int
    
    let name: String
    let creationDate: Date
    
    var updatedDate: Date? = .distantPast
    var displayName: String = ""
    var description: String?
    var removed: Bool = false
    var deleted: Bool = false
    var nsfw: Bool = false
    var avatar: URL?
    var banner: URL?
    var hidden: Bool = false
    var onlyModeratorsCanPost: Bool = false
    
    // This isn't included in the ApiCommunity - it's included in ApiCommunityView, but defined here to maintain similarity with User models. User models don't have the `blocked` property defined in any of the Api types, annoyingly, so we instead request a list of all blocked users and cache the result in `MyUserStub`.
    var blocked: Bool = false
    
    var cacheId: Int {
        var hasher: Hasher = .init()
        hasher.combine(actorId)
        return hasher.finalize()
    }
  
    init(
        source: ApiClient,
        actorId: URL,
        id: Int,
        name: String,
        creationDate: Date,
        updatedDate: Date? = .distantPast,
        displayName: String = "",
        description: String? = nil,
        removed: Bool = false,
        deleted: Bool = false,
        nsfw: Bool = false,
        avatar: URL? = nil,
        banner: URL? = nil,
        hidden: Bool = false,
        onlyModeratorsCanPost: Bool = false,
        blocked: Bool = false
    ) {
        self.source = source
        self.actorId = actorId
        self.id = id
        self.name = name
        self.creationDate = creationDate
        self.updatedDate = updatedDate
        self.displayName = displayName
        self.description = description
        self.removed = removed
        self.deleted = deleted
        self.nsfw = nsfw
        self.avatar = avatar
        self.banner = banner
        self.hidden = hidden
        self.onlyModeratorsCanPost = onlyModeratorsCanPost
        self.blocked = blocked
    }

    // TODO: memberwise?
    func update(with community: ApiCommunity) {
        updatedDate = community.updated
        displayName = community.title
        description = community.description
        removed = community.removed
        deleted = community.deleted
        nsfw = community.nsfw
        avatar = community.icon
        banner = community.banner
        hidden = community.hidden
        onlyModeratorsCanPost = community.postingRestrictedToMods
    }
}
