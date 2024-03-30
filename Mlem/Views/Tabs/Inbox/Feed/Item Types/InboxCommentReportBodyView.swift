//
//  InboxCommentReportBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-03-28.
//

import Foundation
import SwiftUI

struct InboxCommentReportBodyView: View {
    @ObservedObject var commentReport: CommentReportModel
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    
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
                        .foregroundColor(.accentColor)
                        .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                }
                
                VStack(alignment: .leading, spacing: AppConstants.halfSpacing) {
                    Text("Comment reported for: ")
                        .font(.body.smallCaps())
                        .foregroundColor(.secondary)
                    
                    Text(commentReport.commentReport.reason)
                }
                
                EmbeddedCommentView(comment: commentReport.comment, post: nil, community: commentReport.community)
            }
            .padding(.top, AppConstants.standardSpacing)
            .padding(.horizontal, AppConstants.standardSpacing)
  
            // TODO: NEXT reenable
//            InteractionBarView(
//                votes: .init(upvotes: 0, downvotes: 0, myVote: .resetVote),
//                published: commentReport.published,
//                updated: commentReport.commentReport.updated,
//                commentCount: 0,
//                saved: false,
//                accessibilityContext: "comment report",
//                widgets: layoutWidgetTracker.groups.moderator,
//                upvote: {},
//                downvote: {},
//                save: {},
//                reply: {},
//                shareURL: nil
//            )
        }
    }
}
