//
//  Post.swift
//  Mlem
//
//  Created by tht7 on 23/06/2023.
//

import Foundation
import SwiftUI

struct PostLinkWithContext: Equatable, Identifiable, Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }

    var id: Int { post.id }

    let post: APIPostView
    let postTracker: PostTracker
    let feedType: Binding<FeedType>

}
