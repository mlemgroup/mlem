//
//  CommunityTier1.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation
import SwiftUI

protocol CommunityCore1Providing {
    var name: String { get }
    var creationDate: Date { get }
    var actorId: URL { get }
    var updatedDate: Date? { get }
    
    var displayName: String { get }
    var description: String? { get }
    var removed: Bool { get }
    var deleted: Bool { get }
    var nsfw: Bool { get }
    var avatar: URL? { get }
    var banner: URL? { get }
    var hidden: Bool { get }
    var onlyModeratorsCanPost: Bool { get }
}

protocol CommunityCore: CoreModel {
    /// Returns the highest tier of CommunityCore model that is already cached.
    var highestCachedTier: any CommunityCore1Providing { get }
}

@Observable
final class CommunityCore1: CommunityCore1Providing, CommunityCore {
    typealias BaseEquivalent = Community1
    static var cache: CoreContentCache<CommunityCore1> = .init()
    typealias APIType = APICommunity

    let actorId: URL
    
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
    
    required init(from community: APICommunity) {
        self.actorId = community.actorId
        self.name = community.name
        self.creationDate = community.published
        
        self.update(with: community)
    }
    
    func update(with community: APICommunity, cascade: Bool = true) {
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
    
    var highestCachedTier: any CommunityCore1Providing {
        CommunityCore2.cache.retrieveModel(actorId: actorId) ?? self
    }
}
