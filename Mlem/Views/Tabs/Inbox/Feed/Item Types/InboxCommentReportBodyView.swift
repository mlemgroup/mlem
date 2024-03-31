//
//  InboxCommentReportBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-28.
//

import Dependencies
import Foundation
import SwiftUI

struct InboxCommentReportBodyView: View {
    @Dependency(\.errorHandler) var errorHandler
    
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    @EnvironmentObject var modToolTracker: ModToolTracker
    @EnvironmentObject var inboxTracker: InboxTracker
    
    @ObservedObject var commentReport: CommentReportModel
    
    var body: some View {
        content
    }
    
    var iconName: String { commentReport.commentReport.resolved ? Icons.commentReport : Icons.commentReportFill }
    
    var content: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
                HStack {
                    UserLinkView(user: commentReport.reporter, serverInstanceLocation: .bottom, bannedFromCommunity: false)
                    
                    Spacer()
                    
                    Image(systemName: iconName)
                        .foregroundColor(.moderation)
                        .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                    
                    EllipsisMenu(size: AppConstants.largeAvatarSize, menuFunctions: .init()) // TODO: NEXT
                }
                
                Text(commentReport.commentReport.reason)
                
                Text("Reported \(commentReport.published.getRelativeTime())")
                    .italic()
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                if let resolver = commentReport.resolver {
                    let verb = commentReport.commentReport.resolved ? "Resolved" : "Unresolved"
                    Text("\(verb) by \(resolver.fullyQualifiedUsername ?? resolver.name)")
                        .italic()
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                EmbeddedCommentView(comment: commentReport.comment, post: nil, community: commentReport.community)
            }
            .padding(.top, AppConstants.standardSpacing)
            .padding(.horizontal, AppConstants.standardSpacing)
            
            InteractionBarView(context: .comment, widgets: enrichLayoutWidgets())
        }
    }
    
    func toggleResolved() {
        Task(priority: .userInitiated) {
            await commentReport.toggleResolved()
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
                return .remove(removed: commentReport.removed) {
                    commentReport.removeComment(modToolTracker: modToolTracker, shouldRemove: !commentReport.removed)
                }
            case .purge:
                return .purge
            case .ban:
                return .ban(banned: commentReport.creatorBannedFromCommunity) {
                    commentReport.toggleCommentCreatorBanned(modToolTracker: modToolTracker, inboxTracker: inboxTracker)
                }
            default:
                return nil
            }
        }
    }
}
