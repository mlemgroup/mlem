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
    let postTracker: StandardPostTracker?
    let editPost: PostModel?
    
    /// Initializer for creating a post. If `postTracker` is provided, the new post will be prepended to it.
    init(
        community: CommunityModel,
        postTracker: StandardPostTracker?
    ) {
        self.community = community
        self.postTracker = postTracker
        self.editPost = nil
    }
    
    /// Initializer for editing a post
    init(post: PostModel) {
        self.community = post.community
        self.postTracker = nil
        self.editPost = post
    }
}
