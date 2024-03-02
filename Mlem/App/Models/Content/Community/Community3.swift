//
//  CommunityTier3.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation
import SwiftUI

@Observable
final class Community3: Community3Providing, ContentModel {
    typealias ApiType = ApiGetCommunityResponse
    var community3: Community3 { self }
    let api: ApiClient
    
    let community2: Community2
    
    var instance: Instance1! // TODO: no force unwrapping
    var moderators: [Person1] = .init()
    var discussionLanguages: [Int] = .init()
    
    var cacheId: Int { community2.cacheId }
  
    init(
        api: ApiClient,
        community2: Community2,
        instance: Instance1?,
        moderators: [Person1] = .init(),
        discussionLanguages: [Int] = .init()
    ) {
        self.api = api
        self.community2 = community2
        self.instance = instance
        self.moderators = moderators
        self.discussionLanguages = discussionLanguages
    }
    
    func update(with response: ApiGetCommunityResponse) {
        moderators = response.moderators.map { moderatorView in
            api.caches.person1.createModel(api: api, from: moderatorView.moderator)
        }
        discussionLanguages = response.discussionLanguages
        community2.update(with: response.communityView)
    }
    
    func upgrade() async throws -> Community3 { self }
}
