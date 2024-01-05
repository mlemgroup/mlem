//
//  NEW PostTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-01-04.
//

import Dependencies
import Foundation

enum NewFeedType {
    case all
}

class NewPostTracker: StandardTracker<PostModel> {
    @Dependency(\.postRepository) var postRepository
    
    var unreadOnly: Bool
    var feedType: NewFeedType
    
    // var cursor:
    
    init(internetSpeed: InternetSpeed, sortType: TrackerSortType, unreadOnly: Bool, feedType: NewFeedType) {
        self.unreadOnly = unreadOnly
        self.feedType = feedType
        
        super.init(internetSpeed: internetSpeed, sortType: sortType)
    }
    
    // override func fetchPage(
}
