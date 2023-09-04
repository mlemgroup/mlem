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
    let postTracker: PostTracker
    let editPost: PostModel?
    var responseCallback: ((PostModel) -> Void)?
    
    init(
        community: APICommunity,
        postTracker: PostTracker = PostTracker(shouldPerformMergeSorting: false, internetSpeed: .slow),
        editPost: PostModel? = nil,
        responseCallback: ((PostModel) -> Void)? = nil
    ) {
        self.community = community
        self.postTracker = postTracker
        self.editPost = editPost
        self.responseCallback = responseCallback
    }
}
