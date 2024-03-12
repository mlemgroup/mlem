//
//  ModlogEntry.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

import Foundation
import SwiftUI

struct ModlogIcon {
    let imageName: String
    let color: Color
}

enum ModlogReason {
    case inapplicable, noneGiven
    case reason(String)
}

enum ModlogExpiration {
    case inapplicable, permanent
    case date(Date)
}

struct ModlogEntry: Hashable, Equatable {
    let date: Date
    let description: String
    let reason: ModlogReason
    let expires: ModlogExpiration
    let icon: ModlogIcon
    let contextLinks: [MenuFunction]
    
    init(from apiType: APIModRemovePostView) {
        self.date = apiType.modRemovePost.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        self.description = apiType.modRemovePost.removed ?
            "\(agent) removed post \"\(apiType.post.name)\" from \(apiType.community.name)" :
            "\(agent) restored post \"\(apiType.post.name)\" to \(apiType.community.name)"
        
        self.reason = genReason(reason: apiType.modRemovePost.reason)
        self.expires = .inapplicable
        
        self.icon = apiType.modRemovePost.removed ?
            .init(imageName: Icons.removed, color: .red) :
            .init(imageName: Icons.restored, color: .green)
        
        var contextLinks: [MenuFunction] = genInitialMenuFunctions(for: apiType.moderator)
        contextLinks.append(.navigationMenuFunction(
            text: apiType.post.name,
            imageName: apiType.modRemovePost.removed ? Icons.remove : Icons.restore,
            destination: .lazyLoadPostLinkWithContext(.init(postId: apiType.post.id))
        ))
        contextLinks.append(.navigationMenuFunction(
            text: apiType.community.name,
            imageName: Icons.community,
            destination: .community(CommunityModel(from: apiType.community))
        ))
        self.contextLinks = contextLinks
    }
    
    init(from apiType: APIModLockPostView) {
        self.date = apiType.modLockPost.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        let verb = apiType.modLockPost.locked ? "locked" : "unlocked"
        self.description = "\(agent) \(verb) post \"\(apiType.post.name)\" in \(apiType.community.name)"
        
        self.reason = .inapplicable
        self.expires = .inapplicable
        
        self.icon = .init(imageName: apiType.modLockPost.locked ? Icons.locked : Icons.unlocked, color: .orange)
        
        var contextLinks: [MenuFunction] = .init()
//        if let moderator = apiType.moderator {
//            contextLinks.append(.userFromModel(0, UserModel(from: moderator)))
//        }
//        contextLinks.append(.postFromApiType(1, apiType.post))
//        contextLinks.append(.communityFromApiType(2, apiType.community))
        self.contextLinks = contextLinks
    }
    
    init(from apiType: APIModFeaturePostView) {
        self.date = apiType.modFeaturePost.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        let description: String
        if apiType.modFeaturePost.isFeaturedCommunity {
            description = apiType.modFeaturePost.featured ?
                "\(agent) pinned post \"\(apiType.post.name)\" to \(apiType.community.name)" :
                "\(agent) unpinned post \"\(apiType.post.name)\" from \(apiType.community.name)"
        } else {
            description = apiType.modFeaturePost.featured ?
                "\(agent) pinned post \"\(apiType.post.name)\" (from \(apiType.community.name)) to Local" :
                "\(agent) unpinned post \"\(apiType.post.name)\" (from \(apiType.community.name)) from Local"
        }
        self.description = description
        
        self.reason = .inapplicable
        self.expires = .inapplicable
        
        self.icon = .init(
            imageName: apiType.modFeaturePost.featured ? Icons.pinned : Icons.unpinned,
            color: apiType.modFeaturePost.isFeaturedCommunity ? .green : .red
        )
        
        var contextLinks: [MenuFunction] = .init()
//        if let moderator = apiType.moderator {
//            contextLinks.append(.userFromModel(0, UserModel(from: moderator)))
//        }
//        contextLinks.append(.postFromApiType(1, apiType.post))
//        contextLinks.append(.communityFromApiType(2, apiType.community))
        self.contextLinks = contextLinks
    }
    
    init(from apiType: APIModRemoveCommentView) {
        self.date = apiType.modRemoveComment.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        let verb = apiType.modRemoveComment.removed ? "removed" : "restored"
        self.description = "\(agent) \(verb) comment \"\(apiType.comment.content)\""
        
        // self.reason = apiType.modRemoveComment.removed ? genReason(reason: apiType.modRemoveComment.reason) : .inapplicable
        self.reason = genReason(reason: apiType.modRemoveComment.reason)
        self.expires = .inapplicable
        
        self.icon = apiType.modRemoveComment.removed ?
            .init(imageName: Icons.removed, color: .red) :
            .init(imageName: Icons.restored, color: .green)
        
        var contextLinks: [MenuFunction] = .init()
//        if let moderator = apiType.moderator {
//            contextLinks.append(.userFromModel(0, UserModel(from: moderator)))
//        }
//        contextLinks.append(.commentFromApiType(1, apiType.comment))
        self.contextLinks = contextLinks
    }
    
    init(from apiType: APIModRemoveCommunityView) {
        self.date = apiType.modRemoveCommunity.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        let verb = apiType.modRemoveCommunity.removed ? "removed" : "restored"
        self.description = "\(agent) \(verb) community \(apiType.community.name)"
        
        // self.reason = apiType.modRemoveCommunity.removed ? genReason(reason: apiType.modRemoveCommunity.reason) : .inapplicable
        self.reason = genReason(reason: apiType.modRemoveCommunity.reason)
        self.expires = .inapplicable
        
        self.icon = apiType.modRemoveCommunity.removed ?
            .init(imageName: Icons.removed, color: .red) :
            .init(imageName: Icons.restored, color: .green)
        
        var contextLinks: [MenuFunction] = .init()
//        if let moderator = apiType.moderator {
//            contextLinks.append(.userFromModel(0, UserModel(from: moderator)))
//        }
//        contextLinks.append(.communityFromApiType(1, apiType.community))
        self.contextLinks = contextLinks
    }
    
    init(from apiType: APIModBanFromCommunityView) {
        self.date = apiType.modBanFromCommunity.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        let verb = apiType.modBanFromCommunity.banned ? "banned" : "unbanned"
        self.description = "\(agent) \(verb) user \(apiType.bannedPerson.name) from \(apiType.community.name)"
        
        // self.reason = apiType.modBanFromCommunity.banned ? genReason(reason: apiType.modBanFromCommunity.reason) : .inapplicable
        self.reason = genReason(reason: apiType.modBanFromCommunity.reason)
        self.expires = apiType.modBanFromCommunity.banned ? genExpires(expires: apiType.modBanFromCommunity.expires) : .inapplicable
        
        self.icon = apiType.modBanFromCommunity.banned ?
            .init(imageName: Icons.communityBanned, color: .red) :
            .init(imageName: Icons.communityUnbanned, color: .green)
        
        var contextLinks: [MenuFunction] = .init()
//        if let moderator = apiType.moderator {
//            contextLinks.append(.userFromModel(0, UserModel(from: moderator)))
//        }
//        contextLinks.append(.userFromModel(1, UserModel(from: apiType.bannedPerson)))
//        contextLinks.append(.communityFromApiType(2, apiType.community))
        self.contextLinks = contextLinks
    }
    
    static func == (lhs: ModlogEntry, rhs: ModlogEntry) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(description)
    }
}

// MARK: helpers

private func genInitialMenuFunctions(for moderator: APIPerson?) -> [MenuFunction] {
    var ret: [MenuFunction] = .init()
    if let moderator {
        ret.append(.navigationMenuFunction(
            text: "/u/\(moderator.name)",
            imageName: Icons.moderation,
            destination: .userProfile(.init(from: moderator))
        )
        )
    }
    return ret
}

private func genModeratorAgent(agent: APIPerson?) -> String {
    agent?.name ?? "Moderator"
}

private func genReason(reason: String?) -> ModlogReason {
    if let reason, !reason.isEmpty {
        return .reason(reason)
    }
    return .noneGiven
}

private func genExpires(expires: Date?) -> ModlogExpiration {
    if let expires {
        return .date(expires)
    }
    return .permanent
}
