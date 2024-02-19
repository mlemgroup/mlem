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
    typealias APIType = APIGetCommunityResponse
    var community3: Community3 { self }
    
    let source: any APISource
    
    let community2: Community2
    
    var instance: Instance1!
    var moderators: [Person1] = .init()
    var discussionLanguages: [Int] = .init()
    var defaultPostLanguage: Int?
    
    required init(source: any APISource, from response: APIGetCommunityResponse) {
        self.source = source
        
        if let site = response.site {
            self.instance = .create(from: site)
        } else {
            self.instance = nil
        }
        
        self.community2 = source.caches.community2.createModel(source: source, for: response.community_view)
        update(with: response)
    }
    
    func update(with response: APIGetCommunityResponse) {
        moderators = response.moderators.map { moderatorView in
            source.caches.person1.createModel(source: source, for: moderatorView.moderator)
        }
        discussionLanguages = response.discussionLanguages
        defaultPostLanguage = response.defaultPostLanguage
        community2.update(with: response.communityView)
    }
    
    func upgrade() async throws -> Community3 { self }
}
