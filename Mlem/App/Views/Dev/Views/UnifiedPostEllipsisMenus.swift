//
//  UnifiedPostEllipsisMenus.swift
//  Mlem
//
//  Created by Eric Andrews on 2026-01-04.
//

import MlemMiddleware
import SwiftUI
import Icons
import Actions
import os

/// Ellipsis menu for a post appearing in a larger view context. Posts appearing on their own page (i.e., ExpandedPostView) should
/// place their ellipsis menu in the toolbar.
struct UnifiedPostEllipsisMenus: View {
    @Environment(AppState.self) private var appState
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(NavigationLayer.self) private var navigation
    @Environment(\.reportContext) private var reportContext: Report?
    
    @Setting(\.interactionBar_post) var postInteractionBar
    @Setting(\.menus_modActionGrouping) var moderatorActionGrouping

    // This @State is necessary!
    @State var post: UnifiedPostModel
    
    var size: CGFloat = 24
    
    var body: some View {
        HStack {
            if moderatorActionGrouping == .separateMenu {
                if post.canModerate {
                    EllipsisMenu(
                        icon: .lemmy.moderation,
                        size: size,
                        post: post,
                        type: [.moderator]
                    )
                }
                EllipsisMenu(size: size, post: post, type: [.basic])
            } else {
                EllipsisMenu(size: size, post: post, type: [.basic, .moderator])
            }
        }
    }
}

// MARK: - Action System etc.

private let seeds: [ActionSeed] = [
    .unifiedUpvote
//    .upvote,
//    .downvote,
//    .save,
//    .reply,
//    .selectText,
//    .share,
//    .hide,
//    .createImage,
//    .report,
//    .blockCreator,
//    .edit,
//    .delete
]

private let moderationSeeds: [ActionSeed] = [
    .pin,
    .lock,
    .markNsfw,
    .viewVotes,
    .remove,
    .banCreator,
    .purge,
    .purgeCreator
]

extension EllipsisMenu {
    init(
        icon: Icon = .general.menu,
        size: CGFloat,
        post: UnifiedPostModel,
        type: Set<UnifiedPostEllipsisMenuContent.ActionListType> = [.basic, .moderator]
    ) where Content == UnifiedPostEllipsisMenuContent {
        self.icon = icon
        self.size = size
        
        self.content = UnifiedPostEllipsisMenuContent(post: post, type: type)
    }
}

struct UnifiedPostEllipsisMenuContent: View {
    enum ActionListType {
        case basic, moderator
    }

    let post: UnifiedPostModel
    let type: Set<ActionListType>

    var body: some View {
//        if type.contains(.basic) {
//            Button("Hello") {
//                print("hi")
//            }
//        }
        if type.contains(.basic) {
            ControlGroup {
                ActionButtons { _ in
                    seeds.compactMap { seed in
                        Logger.dev.info("Creating \(String(describing: seed))")
                        let ret = seed.createAction(post)
                        Logger.dev.info("Created \(String(describing: ret))")
                        return ret
                    }
                }
            }
            .controlGroupStyle(.compactMenu)
        }
        if type.contains(.moderator) {
            Section {
                ActionButtons { _ in
                    moderationSeeds.compactMap { $0.createAction(post) }
                }
            }
        }
    }
}

