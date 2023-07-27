//
//  PostEditor.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-25.
//

import Foundation

struct PostEditorModel: Identifiable {
    var id: Int { community.id }
    
    let community: APICommunity
    let appState: AppState
    let postTracker: PostTracker
    let editPost: APIPost?
    
    init(community: APICommunity,
         appState: AppState,
         postTracker: PostTracker = PostTracker(shouldPerformMergeSorting: false),
         editPost: APIPost? = nil) {
        self.community = community
        self.appState = appState
        self.postTracker = postTracker
        self.editPost = editPost
    }
}
