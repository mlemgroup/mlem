//
//  ModToolTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-14.
//

import Foundation

enum ModTool: Hashable, Identifiable {
    // community
    case editCommunity(CommunityModel) // community to edit
    case communityBan(UserModel, CommunityModel, Bool, StandardPostTracker?) // user to ban, community to ban from, should ban
    
    // instance
    case instanceBan(UserModel, Bool) // user to ban, should ban
    
    // general
    case removePost(PostModel, Bool) // post to remove, should remove
    
    static func == (lhs: ModTool, rhs: ModTool) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    var id: Int { hashValue }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .editCommunity(community):
            hasher.combine("edit")
            hasher.combine(community.uid)
        case let .communityBan(user, community, shouldBan, _):
            hasher.combine("communityBan")
            hasher.combine(user.uid)
            hasher.combine(community.uid)
            hasher.combine(shouldBan)
        case let .instanceBan(user, shouldBan):
            hasher.combine("instanceBan")
            hasher.combine(user.uid)
            hasher.combine(shouldBan)
        case let .removePost(post, shouldRemove):
            hasher.combine("removePost")
            hasher.combine(post.uid)
            hasher.combine(shouldRemove)
        }
    }
}

/// Tracker for opening mod tools
class ModToolTracker: ObservableObject {
    @Published var openTool: ModTool?
    
    func editCommunity(_ community: CommunityModel) {
        openTool = .editCommunity(community)
    }
    
    func banUserFromCommunity(
        _ user: UserModel,
        from community: CommunityModel,
        shouldBan: Bool,
        postTracker: StandardPostTracker?
    ) {
        openTool = .communityBan(user, community, shouldBan, postTracker)
    }
    
    func banUserFromInstance(_ user: UserModel, shouldBan: Bool) {
        openTool = .instanceBan(user, shouldBan)
    }
    
    func removePost(_ post: PostModel, shouldRemove: Bool) {
        openTool = .removePost(post, shouldRemove)
    }
}
