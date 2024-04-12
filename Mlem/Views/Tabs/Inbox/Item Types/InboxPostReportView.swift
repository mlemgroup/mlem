//
//  InboxPostReportView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import SwiftUI

struct InboxPostReportView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    @EnvironmentObject var modToolTracker: ModToolTracker
    @EnvironmentObject var modInboxTracker: InboxTracker
    @EnvironmentObject var unreadTracker: UnreadTracker
    
    @ObservedObject var postReport: PostReportModel
    
    var body: some View {
        VStack(spacing: 0) {
            InboxPostReportBodyView(postReport: postReport)
            InteractionBarView(context: .post, widgets: enrichLayoutWidgets())
        }
        .background(Color(uiColor: .systemBackground))
        .contentShape(Rectangle())
        .contextMenu {
            ForEach(postReport.genMenuFunctions(
                modToolTracker: modToolTracker,
                inboxTracker: modInboxTracker,
                unreadTracker: unreadTracker
            )) { menuFunction in
                MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
            }
        }
    }
    
    func toggleResolved() {
        Task(priority: .userInitiated) {
            await postReport.toggleResolved(unreadTracker: unreadTracker)
        }
    }
    
    func enrichLayoutWidgets() -> [EnrichedLayoutWidget] {
        layoutWidgetTracker.groups.moderator.compactMap { baseWidget in
            switch baseWidget {
            case .infoStack:
                return .infoStack(
                    colorizeVotes: false,
                    votes: postReport.votes,
                    published: postReport.post.published,
                    updated: postReport.post.updated,
                    commentCount: postReport.numReplies,
                    unreadCommentCount: 0,
                    saved: false
                )
            case .resolve:
                return .resolve(resolved: postReport.postReport.resolved, resolve: toggleResolved)
            case .remove:
                return .remove(removed: postReport.post.removed) {
                    postReport.togglePostRemoved(modToolTracker: modToolTracker, unreadTracker: unreadTracker)
                }
            case .purge:
                return .purge(purged: postReport.purged) {
                    postReport.purgePost(modToolTracker: modToolTracker)
                }
            case .ban:
                return .ban(banned: postReport.postCreatorBannedFromCommunity, instanceBan: false) {
                    postReport.togglePostCreatorBanned(
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
}
