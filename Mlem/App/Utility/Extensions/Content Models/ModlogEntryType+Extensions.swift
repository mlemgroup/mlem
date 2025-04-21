//
//  ModlogEntryType+Extensions.swift
//  Mlem
//
//  Created by Sjmarf on 2024-12-26.
//

import Icons
import MlemMiddleware
import SwiftUI
import Theming

extension ModlogEntryType {
    var icon: Icon {
        switch self {
        case let .removePost(_, _, removed, _),
             let .removeComment(_, _, _, _, removed, _),
             let .removeCommunity(_, removed, _):
            removed ? .lemmy.remove : .lemmy.restore
        case let .lockPost(_, _, locked: locked):
            locked ? .lemmy.addLock : .lemmy.removeLock
        case let .pinPost(_, _, pinned, _):
            pinned ? .lemmy.addPin : .lemmy.removePin
        case .purgePost, .purgeComment, .purgeCommunity, .purgePerson:
            .lemmy.purge
        case let .hideCommunity(_, hidden, _):
            hidden ? .general.hide : .general.show
        case .transferCommunityOwnership:
            .lemmy.transferCommunity
        case let .updatePersonModeratorStatus(_, _, appointed):
            appointed ? .lemmy.addModerator : .lemmy.removeModerator
        case .updatePersonAdminStatus:
            .lemmy.administration
        case let .banPersonFromCommunity(_, _, banned, _, _):
            banned ? .lemmy.banFromCommunity : .lemmy.unbanFromCommunity
        case let .banPersonFromInstance(_, banned, _, _):
            banned ? .lemmy.banFromInstance : .lemmy.unbanFromInstance
        }
    }
    
    var color: ThemedColor {
        switch self {
        case let .removePost(_, _, removed, _),
             let .removeComment(_, _, _, _, removed, _),
             let .removeCommunity(_, removed, _):
            removed ? .themedNegative : .themedPositive
        case .lockPost:
            .themedLockAccent
        case let .pinPost(_, _, _, type):
            type == .community ? .themedModeration : .themedAdministration
        case .purgePost, .purgeComment, .purgeCommunity, .purgePerson:
            .themedNegative
        case .hideCommunity:
            .themedColorfulAccent(4)
        case .transferCommunityOwnership:
            .themedColorfulAccent(8)
        case let .updatePersonModeratorStatus(_, _, appointed):
            appointed ? .themedModeration : .themedNegative
        case let .updatePersonAdminStatus(_, appointed):
            appointed ? .themedAdministration : .themedNegative
        case let .banPersonFromCommunity(_, _, banned, _, _), let .banPersonFromInstance(_, banned, _, _):
            banned ? .themedNegative : .themedPositive
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
                appointed ? "Administrator was appointed" : "Administrator was removed"
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
