//
//  ModToolTracker.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-02-14.
//

import Foundation
import SwiftUI

enum ModTool: Hashable, Identifiable {
    // community
    case editCommunity(CommunityModel) // community to edit
    case removeCommunity(CommunityModel, Bool) // community to remove, should remove
    
    case purgeContent(any Purgable, UserRemovalWalker)

    case banUser(UserModel, CommunityModel?, Bool?, Bool, UserRemovalWalker, (() -> Void)?)
    // user to ban, community to ban from, is banned from community, should ban, callback

    case addMod(Binding<UserModel>?, Binding<CommunityModel>?) // user to add as mod, community to add mod to
    
    // post
    case removePost(any Removable, Bool, (() -> Void)?) // post to remove, should remove, callback
    
    // comment
    case removeComment(any Removable, Bool, (() -> Void)?) // comment to remove, should remove
    
    case denyApplication(RegistrationApplicationModel)
    
    static func == (lhs: ModTool, rhs: ModTool) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    var id: Int { hashValue }
    
    func hash(into hasher: inout Hasher) {
        switch self {
        case let .editCommunity(community):
            hasher.combine("edit")
            hasher.combine(community.uid)
        case let .banUser(user, community, isBanned, shouldBan, _, _):
            hasher.combine("communityBan")
            hasher.combine(user.uid)
            hasher.combine(community?.uid)
            hasher.combine(isBanned)
            hasher.combine(shouldBan)
        case let .purgeContent(content, _):
            hasher.combine("purge")
            hasher.combine(content.uid)
        case let .addMod(user, community):
            hasher.combine("addMod")
            hasher.combine(user?.wrappedValue.uid)
            hasher.combine(community?.wrappedValue.uid)
        case let .removePost(post, shouldRemove, _):
            hasher.combine("removePost")
            hasher.combine(post)
            hasher.combine(shouldRemove)
        case let .removeComment(comment, shouldRemove, _):
            hasher.combine("removeComment")
            hasher.combine(comment)
            hasher.combine(shouldRemove)
        case let .removeCommunity(community, shouldRemove):
            hasher.combine("removeCommunity")
            hasher.combine(community.uid)
            hasher.combine(shouldRemove)
        case let .denyApplication(application):
            hasher.combine("denyApplication")
            hasher.combine(application)
        }
    }
}

/// Tracker for opening mod tools
class ModToolTracker: ObservableObject {
    @Published var openTool: ModTool?
    
    func editCommunity(_ community: CommunityModel) {
        openTool = .editCommunity(community)
    }
    
    func banUser(
        _ user: UserModel,
        from community: CommunityModel? = nil,
        bannedFromCommunity: Bool = false,
        shouldBan: Bool,
        userRemovalWalker: UserRemovalWalker = .init(),
        callback: (() -> Void)? = nil
    ) {
        openTool = .banUser(user, community, bannedFromCommunity, shouldBan, userRemovalWalker, callback)
    }
    
    func addModerator(user: Binding<UserModel>?, to community: Binding<CommunityModel>?) {
        openTool = .addMod(user, community)
    }
    
    func removePost(_ post: any Removable, shouldRemove: Bool, callback: (() -> Void)? = nil) {
        openTool = .removePost(post, shouldRemove, callback)
    }
    
    func removeComment(_ comment: any Removable, shouldRemove: Bool, callback: (() -> Void)? = nil) {
        openTool = .removeComment(comment, shouldRemove, callback)
    }
    
    func removeCommunity(_ community: CommunityModel, shouldRemove: Bool) {
        openTool = .removeCommunity(community, shouldRemove)
    }
    
    func purgeContent(_ content: Purgable, userRemovalWalker: UserRemovalWalker = .init()) {
        openTool = .purgeContent(content, userRemovalWalker)
    }
    
    func denyApplication(_ application: RegistrationApplicationModel) {
        openTool = .denyApplication(application)
    }
}
