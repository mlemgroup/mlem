//
//  CommunityTier1.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation
import SwiftUI

@Observable
final class CommunityCore1: CoreModel {
    static var cache: CoreContentCache<CommunityCore1> = .init()
    typealias APIType = APICommunity

    let actorId: URL
    
    let name: String
    let creationDate: Date
    
    var updatedDate: Date?
    var displayName: String
    var description: String?
    var removed: Bool
    var deleted: Bool
    var nsfw: Bool
    var avatar: URL?
    var banner: URL?
    var hidden: Bool
    var onlyModeratorsCanPost: Bool
    
    required init(from community: APICommunity) {
        self.actorId = community.actorId
        self.name = community.name
        self.creationDate = community.published
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

