//
//  ModToolTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-14.
//

import Foundation

enum ModTool: Hashable, Identifiable {
    case auditUser(UserModel?, CommunityModel)
    case moderators(CommunityModel)
    case editCommunity(CommunityModel)
    case instanceBan(UserModel?)
    
    var id: Int { hashValue }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .auditUser(userModel, community):
            hasher.combine("auditUser")
            hasher.combine(community.uid)
            hasher.combine(userModel?.uid)
        case let .moderators(community):
            hasher.combine("moderators")
            hasher.combine(community.uid)
        case let .editCommunity(community):
            hasher.combine("edit")
            hasher.combine(community.uid)
        case let .instanceBan(user):
            hasher.combine("instanceBan")
            hasher.combine(user?.uid ?? .init(contentType: .user, contentId: 0))
        }
    }
}

/// Tracker for opening mod tools
class ModToolTracker: ObservableObject {
    @Published var openTool: ModTool?
    
    func editCommunity(_ community: CommunityModel) {
        openTool = .editCommunity(community)
    }
    
    func showModerators(for community: CommunityModel) {
        openTool = .moderators(community)
    }
    
    func audit(in community: CommunityModel) {
        openTool = .auditUser(nil, community)
    }
    
    func auditUser(_ user: UserModel, in community: CommunityModel) {
        openTool = .auditUser(user, community)
    }
    
    func banUserFromInstance(_ user: UserModel) {
        openTool = .instanceBan(user)
    }
}
