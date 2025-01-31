//
//  ModlogEntryType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-26.
//

import MlemMiddleware
import SwiftUI

extension ModlogEntryType {
    var systemImage: String {
        switch self {
        case let .removePost(_, _, removed, _),
             let .removeComment(_, _, _, _, removed, _),
             let .removeCommunity(_, removed, _):
            removed ? Icons.remove : Icons.restore
        case let .lockPost(_, _, locked: locked):
            locked ? Icons.lock : Icons.unlock
        case let .pinPost(_, _, pinned, _):
            pinned ? Icons.pin : Icons.unpin
        case .purgePost, .purgeComment, .purgeCommunity, .purgePerson:
            Icons.purge
        case let .hideCommunity(_, hidden, _):
            hidden ? Icons.hide : Icons.show
        case .transferCommunityOwnership:
            Icons.transferCommunity
        case let .updatePersonModeratorStatus(_, _, appointed):
            appointed ? Icons.moderation : Icons.demoteModerator
        case .updatePersonAdminStatus:
            Icons.administrationFill
        case let .banPersonFromCommunity(_, _, banned, _, _):
            banned ? Icons.banFromCommunity : Icons.unbanFromCommunity
        case let .banPersonFromInstance(_, banned, _, _):
            banned ? Icons.banFromInstance : Icons.unbanFromInstance
        }
    }
    
    var color: Color {
        switch self {
        case let .removePost(_, _, removed, _),
             let .removeComment(_, _, _, _, removed, _),
             let .removeCommunity(_, removed, _):
            removed ? Palette.main.negative : Palette.main.positive
        case .lockPost:
            Palette.main.lockAccent
        case let .pinPost(_, _, _, type):
            type == .community ? Palette.main.moderation : Palette.main.administration
        case .purgePost, .purgeComment, .purgeCommunity, .purgePerson:
            Palette.main.negative
        case .hideCommunity:
            Palette.main.colorfulAccent(4)
        case .transferCommunityOwnership:
            Palette.main.colorfulAccent(8)
        case let .updatePersonModeratorStatus(_, _, appointed):
            appointed ? Palette.main.moderation : Palette.main.negative
        case let .updatePersonAdminStatus(_, appointed):
            appointed ? Palette.main.administration : Palette.main.negative
        case let .banPersonFromCommunity(_, _, banned, _, _), let .banPersonFromInstance(_, banned, _, _):
            banned ? Palette.main.negative : Palette.main.positive
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity function_body_length
    func label(userText: Text?) -> LocalizedStringKey {
        switch self {
        case let .removePost(_, _, removed, _):
            if let userText {
                removed ? "\(userText) removed a post" : "\(userText) restored a post"
            } else {
                removed ? "Post was removed" : "Post was restored"
            }
        case let .removeComment(_, _, _, _, removed, _):
            if let userText {
                removed ? "\(userText) removed a comment" : "\(userText) restored a comment"
            } else {
                removed ? "Comment was removed" : "Comment was restored"
            }
        case let .removeCommunity(_, removed, _):
            if let userText {
                removed ? "\(userText) removed a community" : "\(userText) restored a community"
            } else {
                removed ? "Community was removed" : "Community was restored"
            }
        case let .lockPost(_, _, locked):
            if let userText {
                locked ? "\(userText) locked a post" : "\(userText) unlocked a post"
            } else {
                locked ? "Post was locked" : "Post was unlocked"
            }
        case let .pinPost(_, community, pinned, type):
            pinLabel(userText: userText, community: community, pinned: pinned, type: type)
        case .purgePost:
            if let userText {
                "\(userText) purged a post"
            } else {
                "Post was purged"
            }
        case .purgeComment:
            if let userText {
                "\(userText) purged a comment"
            } else {
                "Comment was purged"
            }
        case .purgeCommunity:
            if let userText {
                "\(userText) purged a community"
            } else {
                "Community was purged"
            }
        case .purgePerson:
            if let userText {
                "\(userText) purged a user"
            } else {
                "User was purged"
            }
        case let .hideCommunity(_, hidden, _):
            if let userText {
                hidden ? "\(userText) hid a community" : "\(userText) unhid a community"
            } else {
                hidden ? "Community was hidden" : "Community was unhidden"
            }
        case .transferCommunityOwnership:
            if let userText {
                "\(userText) transferred ownership of a community"
            } else {
                "Community ownership was transferred"
            }
        case let .updatePersonModeratorStatus(_, _, appointed):
            if let userText {
                appointed ? "\(userText) appointed a moderator" : "\(userText) removed a moderator"
            } else {
                appointed ? "Moderator was appointed" : "Moderator was removed"
            }
        case let .updatePersonAdminStatus(_, appointed):
            if let userText {
                appointed ? "\(userText) appointed an administrator" : "\(userText) removed an administrator"
            } else {
                appointed ? "Adminstrator was appointed" : "Administrator was removed"
            }
        case let .banPersonFromCommunity(_, _, banned, _, _), let .banPersonFromInstance(_, banned, _, _):
            if let userText {
                banned ? "\(userText) banned a user" : "\(userText) unbanned a user"
            } else {
                banned ? "User was banned" : "User was unbanned"
            }
        }
    }
}

private func pinLabel(
    userText: Text?,
    community: Community1,
    pinned: Bool,
    type: ApiPostFeatureType
) -> LocalizedStringKey {
    let target: String = (type == .community ? community.fullName : community.api.host)
    if let userText {
        return pinned ? "\(userText) pinned a post to \(target)" : "\(userText) unpinned a post from \(target)"
    } else {
        return pinned ? "Post was pinned to \(target)" : "Post was unpinned from \(target)"
    }
}
