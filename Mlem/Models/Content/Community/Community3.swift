//
//  CommunityTier3.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation
import SwiftUI

@Observable
final class Community3: Community3Providing, NewContentModel {
    typealias ApiType = ApiGetCommunityResponse
    var community3: Community3 { self }
    
    let source: any ApiSource
    
    let community2: Community2
    
    var instance: Instance1!
    var moderators: [Person1] = .init()
    var discussionLanguages: [Int] = .init()
    
    required init(source: any ApiSource, from response: ApiGetCommunityResponse) {
        self.source = source
        
        if let site = response.site {
            self.instance = .create(from: site)
        } else {
            self.instance = nil
        }
        
        self.community2 = source.caches.community2.createModel(source: source, for: response.communityView)
        update(with: response)
    }
    
    func update(with response: ApiGetCommunityResponse) {
        moderators = response.moderators.map { moderatorView in
            source.caches.person1.createModel(source: source, for: moderatorView.moderator)
        }
        discussionLanguages = response.discussionLanguages
        community2.update(with: response.communityView)
    }
    
    func upgrade() async throws -> Community3 { self }
}
