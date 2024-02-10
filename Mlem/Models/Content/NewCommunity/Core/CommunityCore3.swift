//
//  CommunityTier3.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation
import SwiftUI

@Observable
final class CommunityCore3: CoreModel {
    static var cache: CoreContentCache<CommunityCore3> = .init()
    typealias APIType = GetCommunityResponse
    
    var actorId: URL { core2.core1.actorId }
    
    let core2: CommunityCore2

    private(set) var moderators: [UserModel]
    private(set) var discussionLanguages: [Int]
    private(set) var defaultPostLanguage: Int?
    
    required init(from response: GetCommunityResponse) {
        self.moderators = response.moderators.map { UserModel(from: $0.moderator) }
        self.discussionLanguages = response.discussionLanguages
        self.defaultPostLanguage = response.defaultPostLanguage
        
        self.core2 = CommunityCore2.cache.createModel(for: response.communityView)
    }
    
    func update(with response: GetCommunityResponse) {
        moderators = response.moderators.map { UserModel(from: $0.moderator) }
        discussionLanguages = response.discussionLanguages
        defaultPostLanguage = response.defaultPostLanguage
        core2.update(with: response.communityView)
    }
}
