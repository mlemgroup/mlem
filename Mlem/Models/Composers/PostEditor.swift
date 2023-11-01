//
//  PostEditor.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-25.
//

import Foundation
import SwiftUI

struct PostEditorModel: Identifiable {
    var id: Int { community.communityId }
    
    let community: CommunityModel
    var postTracker: PostTracker!
    let editPost: PostModel?
    var responseCallback: ((PostModel) -> Void)?
    
    init(
        community: CommunityModel,
        postTracker: PostTracker? = nil,
        responseCallback: ((PostModel) -> Void)? = nil
    ) {
        self.community = community
        self.editPost = nil
        self.responseCallback = responseCallback
        self.initialiseTracker(postTracker)
    }
    
    init(
        post: PostModel,
        postTracker: PostTracker? = nil,
        responseCallback: ((PostModel) -> Void)? = nil
    ) {
        self.editPost = post
        self.community = post.community
        self.responseCallback = responseCallback
        self.initialiseTracker(postTracker)
    }
    
    private mutating func initialiseTracker(_ postTracker: PostTracker?) {
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        if let postTracker {
            self.postTracker = postTracker
        } else {
            self.postTracker = .init(shouldPerformMergeSorting: false, internetSpeed: .slow, upvoteOnSave: upvoteOnSave)
        }
    }
}
