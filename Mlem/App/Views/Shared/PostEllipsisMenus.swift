//
//  PostEllipsisMenus.swift
//  Mlem
//
//  Created by Sjmarf on 01/10/2024.
//

import MlemMiddleware
import SwiftUI

/// Ellipsis menu for a post appearing in a larger view context. Posts appearing on their own page (i.e., ExpandedPostView) should
/// place their ellipsis menu in the toolbar.
struct PostEllipsisMenus: View {
    @Environment(AppState.self) private var appState
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(NavigationLayer.self) private var navigation
    @Environment(\.reportContext) private var reportContext: Report?
    
    @Setting(\.interactionBar_post) var postInteractionBar
    @Setting(\.menus_modActionGrouping) var moderatorActionGrouping

    // This @State is necessary!
    @State var post: any Post
    
    var size: CGFloat = 24
    
    var body: some View {
        HStack {
            if post.shouldShowLoadingSymbol(for: postInteractionBar) {
                ProgressView()
            }
            if moderatorActionGrouping == .separateMenu {
                if post.canModerate {
                    EllipsisMenu(icon: .lemmy.moderation, size: size) {
                        post.moderatorMenuActions(appState: appState, showAllActions: false, navigation: navigation, report: reportContext)
                    }
                }
                EllipsisMenu(size: size) {
                    post.basicMenuActions(
                        appState: appState,
                        expanded: false,
                        navigation: navigation,
                        commentTreeTracker: commentTreeTracker
                    )
                }
            } else {
                EllipsisMenu(size: size) {
                    post.allMenuActions(
                        appState: appState,
                        showAllActions: false,
                        navigation: navigation,
                        report: reportContext,
                        commentTreeTracker: commentTreeTracker
                    )
                }
            }
        }
    }
}
