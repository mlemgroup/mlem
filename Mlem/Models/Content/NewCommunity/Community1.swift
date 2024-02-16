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
    typealias APIType = APICommunity
    var community1: Community1 { self }
    var source: any APISource

    let actorId: URL
    let id: Int
    
    let name: String
    let creationDate: Date
    
    var updatedDate: Date? = .distantPast
    var displayName: String = ""
    var description: String? = nil
    var removed: Bool = false
    var deleted: Bool = false
    var nsfw: Bool = false
    var avatar: URL? = nil
    var banner: URL? = nil
    var hidden: Bool = false
    var onlyModeratorsCanPost: Bool = false
    
    // This isn't included in the APICommunity - it's included in APICommunityView, but defined here to maintain similarity with User models. User models don't have the `blocked` property defined in any of the API types, annoyingly, so we instead request a list of all blocked users and cache the result in `MyUserStub`.
    var blocked: Bool = false
    
    required init(source: any APISource, from community: APICommunity) {
        self.source = source
        
        self.actorId = community.actorId
        self.id = community.id
        self.name = community.name
        self.creationDate = community.published

        self.update(with: community)
    }
    
    func update(with community: APICommunity) {
        self.updatedDate = community.updated
        self.displayName = community.title
        self.description = community.description
        self.removed = community.removed
        self.deleted = community.deleted
        self.nsfw = community.nsfw
        self.avatar = community.iconUrl
        self.banner = community.bannerUrl
        self.hidden = community.hidden
        self.onlyModeratorsCanPost = community.postingRestrictedToMods
    }
}
