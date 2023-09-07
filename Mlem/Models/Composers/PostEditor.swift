//
//  PostEditor.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-25.
//

import Foundation
import SwiftUI

struct PostEditorModel: Identifiable {
    var id: Int { community.id }
    
    let community: APICommunity
    let postTracker: PostTracker
    let editPost: PostModel?
    var responseCallback: ((PostModel) -> Void)?
    
    init(
        community: APICommunity,
        postTracker: PostTracker? = nil,
        editPost: PostModel? = nil,
        responseCallback: ((PostModel) -> Void)? = nil
    ) {
        self.community = community
        self.editPost = editPost
        self.responseCallback = responseCallback
        
        @AppStorage("upvoteOnSave") var upvoteOnSave = false
        if let postTracker {
            self.postTracker = postTracker
        } else {
            self.postTracker = .init(shouldPerformMergeSorting: false, internetSpeed: .slow, upvoteOnSave: upvoteOnSave)
        }
    }
}
