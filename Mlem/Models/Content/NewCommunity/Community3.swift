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
    typealias APIType = GetCommunityResponse
    var community3: Community3 { self }
    var community1: Community1 { community2.community1 }
    
    let source: any APISource
    
    let community2: Community2
    
    var instance: Instance1!
    var moderators: [User1] = .init()
    var discussionLanguages: [Int] = .init()
    var defaultPostLanguage: Int? = nil
    
    required init(source: any APISource, from response: GetCommunityResponse) {
        self.source = source
        
        if let site = response.site {
            self.instance = .create(from: site)
        } else {
            self.instance = nil
        }
        
        self.community2 = source.caches.community2.createModel(source: source, for: response.communityView)
        self.update(with: response)
    }
    
    func update(with response: GetCommunityResponse) {
        self.moderators = response.moderators.map { moderatorView in
            source.caches.user1.createModel(source: source, for: moderatorView.moderator)
        }
        self.discussionLanguages = response.discussionLanguages
        self.defaultPostLanguage = response.defaultPostLanguage
        self.community2.update(with: response.communityView)
    }
    
    func upgrade() async throws -> Community3 { self }
}
