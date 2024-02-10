//
//  CommunityTier1.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation
import SwiftUI

protocol CommunityTier1Providing: CommunityStubProviding {
    var name: String { get }
    var creationDate: Date { get }
    var actorID: URL { get }
    var local: Bool { get }
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

@Observable
final class CommunityTier1: CommunityTier1Providing, DependentContentModel {
    typealias APIType = APICommunity
    var source: any APISource
    
    let id: Int
    let name: String
    let creationDate: Date
    let actorID: URL
    let local: Bool
    
    private(set) var updatedDate: Date?
    private(set) var displayName: String
    private(set) var description: String?
    private(set) var removed: Bool
    private(set) var deleted: Bool
    private(set) var nsfw: Bool
    private(set) var avatar: URL?
    private(set) var banner: URL?
    private(set) var hidden: Bool
    private(set) var onlyModeratorsCanPost: Bool
    
    required init(source: any APISource, from community: APICommunity) {
        self.source = source

        self.id = community.id
        self.name = community.name
        self.creationDate = community.published
        self.actorID = community.actorId
        self.local = community.local
        
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

