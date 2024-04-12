//
//  InboxCommentReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-27.
//

import Foundation
import SwiftUI

struct InboxCommentReportView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    @EnvironmentObject var modToolTracker: ModToolTracker
    @EnvironmentObject var modInboxTracker: InboxTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    @ObservedObject var commentReport: CommentReportModel
    
    var body: some View {
        VStack(spacing: 0) {
            InboxCommentReportBodyView(commentReport: commentReport)
            InteractionBarView(context: .comment, widgets: enrichLayoutWidgets())
        }
        .contentShape(Rectangle())
        .background(Color.systemBackground)
        .contextMenu {
            ForEach(commentReport.genMenuFunctions(
                modToolTracker: modToolTracker,
                inboxTracker: modInboxTracker,
                unreadTracker: unreadTracker
            )) { menuFunction in
                MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
            }
        }
    }
    
    func enrichLayoutWidgets() -> [EnrichedLayoutWidget] {
        layoutWidgetTracker.groups.moderator.compactMap { baseWidget in
            switch baseWidget {
            case .infoStack:
                return .infoStack(
                    colorizeVotes: false,
                    votes: commentReport.votes,
                    published: commentReport.comment.published,
                    updated: commentReport.comment.updated,
                    commentCount: commentReport.numReplies,
                    unreadCommentCount: 0,
                    saved: false
                )
            case .resolve:
                return .resolve(resolved: commentReport.commentReport.resolved, resolve: toggleResolved)
            case .remove:
                return .remove(removed: commentReport.comment.removed) {
                    commentReport.toggleCommentRemoved(modToolTracker: modToolTracker, unreadTracker: unreadTracker)
                }
            case .purge:
                return .purge(purged: commentReport.purged) {
                    commentReport.purgeComment(modToolTracker: modToolTracker)
                }
            case .ban:
                return .ban(banned: commentReport.commentCreatorBannedFromCommunity, instanceBan: false) {
                    commentReport.toggleCommentCreatorBanned(
                        modToolTracker: modToolTracker,
                        inboxTracker: modInboxTracker,
                        unreadTracker: unreadTracker
                    )
                }
            default:
                return nil
            }
        }
    }
    
    func toggleResolved() {
        Task(priority: .userInitiated) {
            await commentReport.toggleResolved(unreadTracker: unreadTracker)
        }
    }
}
