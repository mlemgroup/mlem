//
//  Post Link.swift
//  Mlem
//
//  Created by tht7 on 23/06/2023.
//

import Foundation
import SwiftUI

// TODO: ERIC delete this
struct PostLinkWithContext: Equatable, Identifiable, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: Int { post.postId }

    let post: PostModel
    var community: CommunityModel?
    let postTracker: PostTracker
    var scrollTarget: Int?
}

struct NewPostLinkWithContext: Equatable, Identifiable, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var id: Int { post.postId }

    let post: PostModel
    var community: CommunityModel?
    var scrollTarget: Int?
}
