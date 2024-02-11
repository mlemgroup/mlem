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

    let instance: InstanceCore1?
    
    var moderators: [UserCore1]
    var discussionLanguages: [Int]
    var defaultPostLanguage: Int?
    
    required init(from response: GetCommunityResponse) {
        if let site = response.site {
            self.instance = .create(from: site)
        } else {
            self.instance = nil
        }
        
        self.moderators = response.moderators.map { .create(from: $0.moderator) }
        self.discussionLanguages = response.discussionLanguages
        self.defaultPostLanguage = response.defaultPostLanguage
        
        self.core2 = CommunityCore2.cache.createModel(for: response.communityView)
    }
    
    func update(with response: GetCommunityResponse) {
        self.moderators = response.moderators.map { UserCore1.create(from: $0.moderator) }
        self.discussionLanguages = response.discussionLanguages
        self.defaultPostLanguage = response.defaultPostLanguage
        self.core2.update(with: response.communityView)
    }
}
