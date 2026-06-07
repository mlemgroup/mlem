//
//  CommunitySortType+Extensions.swift<Extensions>
//  Mlem
//
//  Created by Sjmarf on 2026-06-07.
//

import Foundation
import Icons
import MlemMiddleware

extension CommunitySortType {
    var label: LocalizedStringResource {
        switch self {
        case .hot: "Hot"
        case .new: "New"
        case .old: "Old"
        case .name: "Name"
        case .commentCount: "Comments"
        case .postCount: "Posts"
        case .subscriberCount: "Subscribers"
        case .localSubscriberCount: "Local Subscribers"
        case .activeUserCount: "Active Users"
        case .federationDate(.ascending): "Oldest Federated"
        case .federationDate(.descending): "Newest Federated"
        case .newPostsOrComments: "Recent Activity"
        }
    }
    
    var icon: Icon {
        switch self {
        case .hot: .lemmy.hotSort
        case .new: .lemmy.newSort
        case .old: .lemmy.oldSort
        case .name: .lemmy.alphabeticalSort
        case .commentCount: .lemmy.comment
        case .postCount: .lemmy.post
        case .subscriberCount: .lemmy.usersSort
        case .localSubscriberCount: .lemmy.usersSort
        case .activeUserCount: .lemmy.activeSort
        case .federationDate: .lemmy.federation
        case .newPostsOrComments: .lemmy.newCommentsSort
        }
    }
}
