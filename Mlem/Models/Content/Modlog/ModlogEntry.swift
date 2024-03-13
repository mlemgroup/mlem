//
//  ModlogEntry.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-11.
//

// swiftlint:disable file_length
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
            "\(agent) removed post \"\(apiType.post.name)\" from \(apiType.community.fullyQualifiedName)" :
            "\(agent) restored post \"\(apiType.post.name)\" to \(apiType.community.fullyQualifiedName)"
        
        self.reason = genReason(reason: apiType.modRemovePost.reason)
        self.expires = .inapplicable
        
        self.icon = apiType.modRemovePost.removed ?
            .init(imageName: Icons.removed, color: .red) :
            .init(imageName: Icons.restored, color: .green)
  
        self.contextLinks = [
            ModlogMenuFunction.moderator(apiType.moderator),
            ModlogMenuFunction.post(apiType.post),
            ModlogMenuFunction.community(apiType.community)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIModLockPostView) {
        self.date = apiType.modLockPost.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        let verb = apiType.modLockPost.locked ? "locked" : "unlocked"
        self.description = "\(agent) \(verb) post \"\(apiType.post.name)\" in \(apiType.community.fullyQualifiedName)"
        
        self.reason = .inapplicable
        self.expires = .inapplicable
        
        let icon = apiType.modLockPost.locked ? Icons.locked : Icons.unlocked
        self.icon = .init(imageName: icon, color: .orange)
        
        self.contextLinks = [
            ModlogMenuFunction.moderator(apiType.moderator),
            ModlogMenuFunction.post(apiType.post),
            ModlogMenuFunction.community(apiType.community)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIModFeaturePostView) {
        self.date = apiType.modFeaturePost.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        let description: String
        if apiType.modFeaturePost.isFeaturedCommunity {
            description = apiType.modFeaturePost.featured ?
                "\(agent) pinned post \"\(apiType.post.name)\" to \(apiType.community.fullyQualifiedName)" :
                "\(agent) unpinned post \"\(apiType.post.name)\" from \(apiType.community.fullyQualifiedName)"
        } else {
            description = apiType.modFeaturePost.featured ?
                "\(agent) pinned post \"\(apiType.post.name)\" (from \(apiType.community.fullyQualifiedName)) to Local" :
                "\(agent) unpinned post \"\(apiType.post.name)\" (from \(apiType.community.fullyQualifiedName)) from Local"
        }
        self.description = description
        
        self.reason = .inapplicable
        self.expires = .inapplicable
        
        self.icon = .init(
            imageName: apiType.modFeaturePost.featured ? Icons.pinned : Icons.unpinned,
            color: apiType.modFeaturePost.isFeaturedCommunity ? .green : .red
        )
        
        self.contextLinks = [
            ModlogMenuFunction.moderator(apiType.moderator),
            ModlogMenuFunction.post(apiType.post),
            ModlogMenuFunction.community(apiType.community)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIModRemoveCommentView) {
        self.date = apiType.modRemoveComment.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        let verb = apiType.modRemoveComment.removed ? "removed" : "restored"
        self.description = "\(agent) \(verb) comment \"\(apiType.comment.content)\" (posted in \(apiType.community.fullyQualifiedName))"
        
        // self.reason = apiType.modRemoveComment.removed ? genReason(reason: apiType.modRemoveComment.reason) : .inapplicable
        self.reason = genReason(reason: apiType.modRemoveComment.reason)
        self.expires = .inapplicable
        
        self.icon = apiType.modRemoveComment.removed ?
            .init(imageName: Icons.removed, color: .red) :
            .init(imageName: Icons.restored, color: .green)
        
        self.contextLinks = [
            ModlogMenuFunction.moderator(apiType.moderator),
            ModlogMenuFunction.comment(apiType.comment),
            ModlogMenuFunction.post(apiType.post),
            ModlogMenuFunction.community(apiType.community)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIModRemoveCommunityView) {
        self.date = apiType.modRemoveCommunity.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        let verb = apiType.modRemoveCommunity.removed ? "removed" : "restored"
        self.description = "\(agent) \(verb) community \(apiType.community.fullyQualifiedName)"
        
        self.reason = genReason(reason: apiType.modRemoveCommunity.reason)
        self.expires = .inapplicable
        
        self.icon = apiType.modRemoveCommunity.removed ?
            .init(imageName: Icons.removed, color: .red) :
            .init(imageName: Icons.restored, color: .green)
        
        self.contextLinks = [
            ModlogMenuFunction.moderator(apiType.moderator),
            ModlogMenuFunction.community(apiType.community)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIModBanFromCommunityView) {
        self.date = apiType.modBanFromCommunity.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        let verb = apiType.modBanFromCommunity.banned ? "banned" : "unbanned"
        self.description = "\(agent) \(verb) \(apiType.bannedPerson.fullyQualifiedName) from \(apiType.community.fullyQualifiedName)"
        
        self.reason = genReason(reason: apiType.modBanFromCommunity.reason)
        self.expires = apiType.modBanFromCommunity.banned ? genExpires(expires: apiType.modBanFromCommunity.expires) : .inapplicable
        
        self.icon = apiType.modBanFromCommunity.banned ?
            .init(imageName: Icons.communityBanned, color: .red) :
            .init(imageName: Icons.communityUnbanned, color: .green)
        
        self.contextLinks = [
            ModlogMenuFunction.moderator(apiType.moderator),
            ModlogMenuFunction.user(apiType.bannedPerson, verb.capitalized),
            ModlogMenuFunction.community(apiType.community)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIModBanView) {
        self.date = apiType.modBan.when_
        
        let agent = genAdministratorAgent(agent: apiType.moderator)
        let verb = apiType.modBan.banned ? "banned" : "unbanned"
        // swiftlint:disable:next line_length
        self.description = "\(agent) \(verb) \(apiType.bannedPerson.fullyQualifiedName) from \(apiType.moderator?.actorId.host() ?? "instance")"
        
        self.reason = genReason(reason: apiType.modBan.reason)
        self.expires = apiType.modBan.banned ? genExpires(expires: apiType.modBan.expires) : .inapplicable
        
        self.icon = apiType.modBan.banned ?
            .init(imageName: Icons.instanceBanned, color: .red) :
            .init(imageName: Icons.instanceUnbanned, color: .green)
        
        self.contextLinks = [
            ModlogMenuFunction.moderator(apiType.moderator),
            ModlogMenuFunction.user(apiType.bannedPerson, verb.capitalized)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIModAddCommunityView) {
        self.date = apiType.modAddCommunity.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        let verb = apiType.modAddCommunity.removed ? "removed" : "appointed"
        // swiftlint:disable:next line_length
        self.description = "\(agent) \(verb) \(apiType.moddedPerson.fullyQualifiedName) as moderator of \(apiType.community.fullyQualifiedName)"
        
        self.reason = .inapplicable
        self.expires = .inapplicable
        
        self.icon = apiType.modAddCommunity.removed ?
            .init(imageName: Icons.unmodFill, color: .red) :
            .init(imageName: Icons.moderationFill, color: .green)
        
        self.contextLinks = [
            ModlogMenuFunction.moderator(apiType.moderator),
            ModlogMenuFunction.user(apiType.moddedPerson, apiType.modAddCommunity.removed ? "Unmodded" : "Modded")
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIModTransferCommunityView) {
        self.date = apiType.modTransferCommunity.when_
        
        let agent = genModeratorAgent(agent: apiType.moderator)
        self.description = "\(agent) transferred \(apiType.community.fullyQualifiedName) to \(apiType.moddedPerson.fullyQualifiedName)"
        
        self.reason = .inapplicable
        self.expires = .inapplicable
        
        self.icon = .init(imageName: Icons.leftRight, color: .green)
        
        self.contextLinks = [
            ModlogMenuFunction.moderator(apiType.moderator),
            ModlogMenuFunction.user(apiType.moddedPerson, "Promoted"),
            ModlogMenuFunction.community(apiType.community)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIModAddView) {
        self.date = apiType.modAdd.when_
        
        let agent = genAdministratorAgent(agent: apiType.moderator)
        let verb = apiType.modAdd.removed ? "removed" : "appointed"
        let instance = apiType.moderator?.actorId.host() ?? "instance"
        self.description = "\(agent) \(verb) \(apiType.moddedPerson.fullyQualifiedName) as administrator of \(instance)"
        
        self.reason = .inapplicable
        self.expires = .inapplicable
        
        self.icon = apiType.modAdd.removed ?
            .init(imageName: Icons.unAdmin, color: .indigo) :
            .init(imageName: Icons.admin, color: .teal)
        
        self.contextLinks = [
            ModlogMenuFunction.administrator(apiType.moderator),
            ModlogMenuFunction.user(apiType.moddedPerson, apiType.modAdd.removed ? "Demoted" : "Promoted")
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIAdminPurgePersonView) {
        self.date = apiType.adminPurgePerson.when_
        
        let agent = genAdministratorAgent(agent: apiType.admin)
        self.description = "\(agent) purged a person"
        
        self.reason = genReason(reason: apiType.adminPurgePerson.reason)
        self.expires = .inapplicable
        
        self.icon = .init(imageName: Icons.purge, color: .primary)
        
        self.contextLinks = [
            ModlogMenuFunction.administrator(apiType.admin)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIAdminPurgeCommunityView) {
        self.date = apiType.adminPurgeCommunity.when_
        
        let agent = genAdministratorAgent(agent: apiType.admin)
        self.description = "\(agent) purged a community"
        
        self.reason = genReason(reason: apiType.adminPurgeCommunity.reason)
        self.expires = .inapplicable
        
        self.icon = .init(imageName: Icons.purge, color: .primary)
        
        self.contextLinks = [
            ModlogMenuFunction.administrator(apiType.admin)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIAdminPurgePostView) {
        self.date = apiType.adminPurgePost.when_
        
        let agent = genAdministratorAgent(agent: apiType.admin)
        self.description = "\(agent) purged a post from \(apiType.community.fullyQualifiedName)"
        
        self.reason = genReason(reason: apiType.adminPurgePost.reason)
        self.expires = .inapplicable
        
        self.icon = .init(imageName: Icons.purge, color: .primary)
        
        self.contextLinks = [
            ModlogMenuFunction.administrator(apiType.admin),
            ModlogMenuFunction.community(apiType.community)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIAdminPurgeCommentView) {
        self.date = apiType.adminPurgeComment.when_
        
        let agent = genAdministratorAgent(agent: apiType.admin)
        self.description = "\(agent) purged a comment from \"\(apiType.post.name)\""
        
        self.reason = genReason(reason: apiType.adminPurgeComment.reason)
        self.expires = .inapplicable
        
        self.icon = .init(imageName: Icons.purge, color: .primary)
        
        self.contextLinks = [
            ModlogMenuFunction.administrator(apiType.admin),
            ModlogMenuFunction.post(apiType.post)
        ].compactMap { $0.toMenuFunction() }
    }
    
    init(from apiType: APIModHideCommunityView) {
        self.date = apiType.modHideCommunity.when_
        
        let agent = genAdministratorAgent(agent: apiType.admin)
        let verb = apiType.modHideCommunity.hidden ? "hid" : "unhid"
        self.description = "\(agent) \(verb) community \(apiType.community.fullyQualifiedName)"
        
        self.reason = genReason(reason: apiType.modHideCommunity.reason)
        self.expires = .inapplicable
        
        self.icon = apiType.modHideCommunity.hidden ?
            .init(imageName: Icons.hide, color: .red) :
            .init(imageName: Icons.show, color: .green)
        
        self.contextLinks = [
            ModlogMenuFunction.administrator(apiType.admin),
            ModlogMenuFunction.community(apiType.community)
        ].compactMap { $0.toMenuFunction() }
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

private enum ModlogMenuFunction {
    case administrator(APIPerson?)
    case moderator(APIPerson?)
    case user(APIPerson, String) // user, verb
    case post(APIPost)
    case comment(APIComment)
    case community(APICommunity)
    
    func toMenuFunction() -> MenuFunction? {
        switch self {
        case let .administrator(administrator):
            guard let administrator else { return nil }
            return .navigationMenuFunction(
                text: "View Administrator",
                imageName: Icons.moderation,
                destination: .userProfile(.init(from: administrator))
            )
        case let .moderator(moderator):
            guard let moderator else { return nil }
            return .navigationMenuFunction(
                text: "View Moderator",
                imageName: Icons.moderation,
                destination: .userProfile(.init(from: moderator))
            )
        case let .user(user, verb):
            return .navigationMenuFunction(
                text: "View \(verb) User",
                imageName: Icons.user,
                destination: .userProfile(.init(from: user))
            )
        case let .post(post):
            return .navigationMenuFunction(
                text: "View Post",
                imageName: Icons.posts,
                destination: .lazyLoadPostLinkWithContext(.init(postId: post.id))
            )
        case let .comment(comment):
            return .navigationMenuFunction(
                text: "View Comment",
                imageName: Icons.replies,
                destination: .lazyLoadPostLinkWithContext(.init(postId: comment.postId, scrollTarget: comment.id))
            )
        case let .community(community):
            return .navigationMenuFunction(
                text: "View Community",
                imageName: Icons.community,
                destination: .community(.init(from: community))
            )
        }
    }
}

private func genAdministratorAgent(agent: APIPerson?) -> String {
    agent?.fullyQualifiedName ?? "Administrator"
}

private func genModeratorAgent(agent: APIPerson?) -> String {
    agent?.fullyQualifiedName ?? "Moderator"
}

private func genReason(reason: String?) -> ModlogReason {
    if let strippedReason = reason?.trimmingCharacters(in: .whitespacesAndNewlines), !strippedReason.isEmpty {
        return .reason(strippedReason)
    }
    return .noneGiven
}

private func genExpires(expires: Date?) -> ModlogExpiration {
    if let expires {
        return .date(expires)
    }
    return .permanent
}

extension APIPerson {
    var fullyQualifiedName: String {
        "\(name)@\(actorId.host() ?? "unknown")"
    }
}

extension APICommunity {
    var fullyQualifiedName: String {
        "\(name)@\(actorId.host() ?? "unknown")"
    }
}

// swiftlint:enable file_length
