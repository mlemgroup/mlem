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
    
    var body: some View {
        content
            .padding(AppConstants.standardSpacing)
    }
    
    var iconName: String { commentReport.commentReport.resolved ? Icons.commentReport : Icons.commentReportFill }
    
    var content: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            Text("Comment Report")
                .font(.headline.smallCaps())
                .padding(.bottom, AppConstants.standardSpacing)
            
            UserLinkView(user: commentReport.reporter, serverInstanceLocation: .bottom, bannedFromCommunity: false)
            
            HStack(alignment: .top, spacing: AppConstants.standardSpacing) {
                Image(systemName: iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                
                VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
                    Text(commentReport.commentReport.reason)
                    
                    EmbeddedCommentView(comment: commentReport.comment)
                }
            }
            
            CommunityLinkView(community: commentReport.community)
            
            actionBar
        }
    }
    
    @ViewBuilder
    var actionBar: some View {
        HStack {
            markResolvedButton
            
            removeCommentButton
            
            banUserButton
            
            Spacer()
            
            PublishedTimestampView(date: commentReport.published)
        }
    }
    
    var markResolvedButton: some View {
        Button {
            print("TODO: mark resolved")
        } label: {
            Image(systemName: Icons.resolve)
                .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
        }
        .buttonStyle(.plain)
    }
    
    var removeCommentButton: some View {
        Button {
            print("TODO: remove comment")
        } label: {
            Image(systemName: Icons.remove)
                .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
        }
        .buttonStyle(.plain)
    }
    
    var banUserButton: some View {
        Button {
            print("TODO: ban user")
        } label: {
            Image(systemName: Icons.communityBan)
                .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
        }
        .buttonStyle(.plain)
    }
}
