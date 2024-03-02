//
//  CommunityTier2.swift
//  Mlem
//
//  Created by Sjmarf on 03/02/2024.
//

import Dependencies
import Observation
import SwiftUI

@Observable
final class Community2: Community2Providing {
    var community2: Community2 { self }
    var api: ApiClient

    let community1: Community1
    
    var subscribed: Bool = false
    var favorited: Bool = false

    var subscriberCount: Int = 0
    var postCount: Int = 0
    var commentCount: Int = 0
    var activeUserCount: ActiveUserCount = .zero

    init(
        api: ApiClient,
        community1: Community1,
        subscribed: Bool = false,
        favorited: Bool = false,
        subscriberCount: Int = 0,
        postCount: Int = 0,
        commentCount: Int = 0,
        activeUserCount: ActiveUserCount = .zero
    ) {
        self.api = api
        self.community1 = community1
        self.subscribed = subscribed
        self.favorited = favorited
        self.subscriberCount = subscriberCount
        self.postCount = postCount
        self.commentCount = commentCount
        self.activeUserCount = activeUserCount
    }
}
