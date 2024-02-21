//
//  CommunityTier1.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation
import SwiftUI

@Observable
final class Community1: Community1Providing, NewContentModel {
    typealias ApiType = ApiCommunity
    var community1: Community1 { self }
    var source: any ApiSource

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
    
    required init(source: any ApiSource, from community: ApiCommunity) {
        self.source = source
        
        self.actorId = community.actorId
        self.id = community.id
        self.name = community.name
        self.creationDate = community.published

        update(with: community)
    }
    
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
