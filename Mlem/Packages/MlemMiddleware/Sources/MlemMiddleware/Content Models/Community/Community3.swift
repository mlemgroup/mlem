//
//  CommunityTier3.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Observation

@Observable
public final class Community3: Community3Providing {
    public static let tierNumber: Int = 3
    public var community3: Community3 { self }
    public let api: ApiClient
    
    public let community2: Community2
    
    public var instance: Instance1?
    public var moderators: [Person1]
    public var discussionLanguageIds: Set<Int>
  
    init(
        api: ApiClient,
        community2: Community2,
        instance: Instance1?,
        moderators: [Person1],
        discussionLanguageIds: Set<Int>
    ) {
        self.api = api
        self.community2 = community2
        self.instance = instance
        self.moderators = moderators
        self.discussionLanguageIds = discussionLanguageIds
    }
}
