//
//  ModToolTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-14.
//

import Foundation

enum ModTool: Hashable, Identifiable {
    case editCommunity(CommunityModel) // community to edit
    case instanceBan(UserModel, Bool) // user to ban, should ban
    case communityBan(UserModel, CommunityModel, Bool) // user to ban, community to ban from, should ban
    
    var id: Int { hashValue }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .editCommunity(community):
            hasher.combine("edit")
            hasher.combine(community.uid)
        case let .instanceBan(user, shouldBan):
            hasher.combine("instanceBan")
            hasher.combine(user.uid)
            hasher.combine(shouldBan)
        case let .communityBan(user, community, shouldBan):
            hasher.combine("communityBan")
            hasher.combine(user.uid)
            hasher.combine(community.uid)
            hasher.combine(shouldBan)
        }
    }
}

/// Tracker for opening mod tools
class ModToolTracker: ObservableObject {
    @Published var openTool: ModTool?
    
    func editCommunity(_ community: CommunityModel) {
        openTool = .editCommunity(community)
    }
    
    func banUserFromInstance(_ user: UserModel, shouldBan: Bool) {
        openTool = .instanceBan(user, shouldBan)
    }
    
    func banUserFromCommunity(_ user: UserModel, from community: CommunityModel, shouldBan: Bool) {
        openTool = .communityBan(user, community, shouldBan)
    }
}
