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
    
    @EnvironmentObject var modToolTracker: ModToolTracker
    @EnvironmentObject var modInboxTracker: InboxTracker
    
    @ObservedObject var commentReport: CommentReportModel
    
    var iconName: String { commentReport.commentReport.resolved ? Icons.commentReport : Icons.commentReportFill }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                UserLinkView(user: commentReport.reporter, serverInstanceLocation: .bottom, bannedFromCommunity: false)
                
                Spacer()
                
                Image(systemName: iconName)
                    .foregroundColor(.red)
                    .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                
                EllipsisMenu(
                    size: AppConstants.largeAvatarSize,
                    menuFunctions: commentReport.genMenuFunctions(modToolTracker: modToolTracker, inboxTracker: modInboxTracker)
                )
            }
            
            Text(commentReport.commentReport.reason)
            
            Text("Comment reported \(commentReport.published.getRelativeTime())")
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
    }
}
