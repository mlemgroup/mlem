//
//  CommunityTier3.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation
import SwiftUI

@Observable
final class CommunityTier3: CommunityTier2Providing, DependentContentModel {
    typealias APIType = GetCommunityResponse
    var source: any APISource
    
    // Forward properties from CommunityTier1
    var id: Int { community2.community1.id }
    var name: String { community2.community1.name }
    var creationDate: Date { community2.community1.creationDate }
    var actorID: URL { community2.community1.actorID }
    var local: Bool { community2.community1.local }
    var updatedDate: Date? { community2.community1.updatedDate }
    var displayName: String { community2.community1.displayName }
    var description: String? { community2.community1.description }
    var removed: Bool { community2.community1.removed }
    var deleted: Bool { community2.community1.deleted }
    var nsfw: Bool { community2.community1.nsfw }
    var avatar: URL? { community2.community1.avatar }
    var banner: URL? { community2.community1.banner }
    var hidden: Bool { community2.community1.hidden }
    var onlyModeratorsCanPost: Bool { community2.community1.onlyModeratorsCanPost }
    
    // Forward properties from CommunityTier2
    var subscriberCount: Int { community2.subscriberCount }
    var postCount: Int { community2.postCount }
    var commentCount: Int { community2.commentCount }
    var activeUserCount: ActiveUserCount { community2.activeUserCount }
    
    let community2: CommunityTier2

    private(set) var moderators: [UserModel]
    private(set) var discussionLanguages: [Int]
    private(set) var defaultPostLanguage: Int?
    
    required init(source: any APISource, from response: GetCommunityResponse) {
        self.source = source
        self.moderators = response.moderators.map { UserModel(from: $0.moderator) }
        self.discussionLanguages = response.discussionLanguages
        self.defaultPostLanguage = response.defaultPostLanguage
        self.community2 = source.caches.community2.createModel(source: source, for: response.communityView)
    }
    
    func update(with response: GetCommunityResponse) {
        moderators = response.moderators.map { UserModel(from: $0.moderator) }
        discussionLanguages = response.discussionLanguages
        defaultPostLanguage = response.defaultPostLanguage
        community2.update(with: response.communityView)
    }
}
