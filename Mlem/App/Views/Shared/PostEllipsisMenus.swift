//
//  PostEllipsisMenus.swift
//  Mlem
//
//  Created by Sjmarf on 01/10/2024.
//

import MlemMiddleware
import SwiftUI

struct PostEllipsisMenus: View {
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(NavigationLayer.self) private var navigation
    @Environment(\.reportContext) private var reportContext: Report?
    
    @Setting(\.moderatorActionGrouping) var moderatorActionGrouping

    // This @State is necessary!
    @State var post: any Post
    
    var size: CGFloat = 24
    
    var body: some View {
        HStack {
            if post.shouldShowLoadingSymbol(for: InteractionBarTracker.main.postInteractionBar) {
                ProgressView()
            }
            if moderatorActionGrouping == .separateMenu {
                if post.canModerate {
                    EllipsisMenu(systemImage: Icons.moderation, size: 24) {
                        post.moderatorMenuActions(showAllActions: false, navigation: navigation, report: reportContext)
                    }
                }
                EllipsisMenu(size: 24) {
                    post.basicMenuActions(commentTreeTracker: commentTreeTracker)
                }
            } else {
                EllipsisMenu(size: 24) {
                    post.allMenuActions(
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
