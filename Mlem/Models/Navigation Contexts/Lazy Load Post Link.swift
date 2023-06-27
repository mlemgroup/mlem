//
//  Lazyload Post Link.swift
//  Mlem
//
//  Created by Jake Shirley on 6/26/23.
//

import Foundation

struct LazyLoadPostLinkWithContext: Equatable, Identifiable, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    var id: Int { post.id }

    let post: APIPost
    let postTracker: PostTracker
}
