//
//  CommunityTier3.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation
import SwiftUI

protocol CommunityCore3Providing: CommunityCore2Providing {
    var instance: InstanceCore1? { get }
    var moderators: [any UserCore1Providing] { get }
    var discussionLanguages: [Int] { get }
    var defaultPostLanguage: Int? { get }
}

@Observable
final class CommunityCore3: CommunityCore3Providing, CommunityCore {
    typealias BaseEquivalent = Community3
    static var cache: CoreContentCache<CommunityCore3> = .init()
    typealias APIType = GetCommunityResponse
    
    let core2: CommunityCore2

    let instance: InstanceCore1?
    var _moderators: [UserCore1] = .init()
    var moderators: [any UserCore1Providing] { _moderators }
    var discussionLanguages: [Int] = .init()
    var defaultPostLanguage: Int? = nil
    
    // Forwarded properties from CommunityCore1
    var actorId: URL { core2.actorId }
    var name: String { core2.name }
    var creationDate: Date { core2.creationDate }
    var updatedDate: Date? { core2.updatedDate }
    var displayName: String { core2.displayName }
    var description: String? { core2.description }
    var removed: Bool { core2.removed }
    var deleted: Bool { core2.deleted }
    var nsfw: Bool { core2.nsfw }
    var avatar: URL? { core2.avatar }
    var banner: URL? { core2.banner }
    var hidden: Bool { core2.hidden }
    var onlyModeratorsCanPost: Bool { core2.onlyModeratorsCanPost }
    
    // Forwarded properties from CommunityCore2
    var subscriberCount: Int { core2.subscriberCount }
    var postCount: Int { core2.postCount }
    var commentCount: Int { core2.commentCount }
    var activeUserCount: ActiveUserCount { core2.activeUserCount }
    
    required init(from response: GetCommunityResponse) {
        if let site = response.site {
            self.instance = .create(from: site)
        } else {
            self.instance = nil
        }
        self.core2 = CommunityCore2.cache.createModel(for: response.communityView)
        self.update(with: response, cascade: false)
    }
    
    func update(with response: GetCommunityResponse, cascade: Bool = true) {
        self._moderators = response.moderators.map { UserCore1.create(from: $0.moderator) }
        self.discussionLanguages = response.discussionLanguages
        self.defaultPostLanguage = response.defaultPostLanguage
        if cascade {
            self.core2.update(with: response.communityView)
        }
    }
    
    var highestCachedTier: any CommunityCore1Providing { self }
}
