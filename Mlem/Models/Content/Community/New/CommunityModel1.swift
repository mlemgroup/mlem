//
//  CommunityModel1.swift
//  Mlem
//
//  Created by Sjmarf on 02/02/2024.
//

import Dependencies
import SwiftUI
import Observation

@Observable
class CommunityModel1 {
    // Constant values
    let communityId: Int
    let creationDate: Date
    let actorId: URL
    let local: Bool

    // These aren't settable from outside
    let updatedDate: Date?

    // These will be settable in future
    private(set) var name: String
    private(set) var displayName: String
    private(set) var removed: Bool
    private(set) var deleted: Bool
    private(set) var nsfw: Bool
    private(set) var avatarURL: URL?
    private(set) var bannerURL: URL?
    private(set) var onlyModeratorsCanPost: Bool
    private(set) var hidden: Bool
}

extension CommunityModel1: NewContentModel {
    static var cache: ContentCache<CommunityModel1> = .init()
    typealias APIType = APICommunity

    required init(from community: APICommunity) {
        self.communityId = community.id
        self.creationDate = community.published
        self.actorId = community.actorId
        self.local = community.local
        self.updatedDate = community.updatedDate
    }
}