//
//  InboxPostReportBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Foundation
import SwiftUI

struct InboxPostReportBodyView: View {
    @EnvironmentObject var modToolTracker: ModToolTracker
    @EnvironmentObject var modInboxTracker: InboxTracker
    
    @ObservedObject var postReport: PostReportModel
    
    var iconName: String { postReport.postReport.resolved ? Icons.posts : Icons.postsFill }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.standardSpacing) {
            HStack {
                UserLinkView(user: postReport.reporter, serverInstanceLocation: .bottom, bannedFromCommunity: false)
                
                Spacer()
                
                Image(systemName: iconName)
                    .foregroundColor(.red)
                    .frame(width: AppConstants.largeAvatarSize, height: AppConstants.largeAvatarSize)
                
                EllipsisMenu(
                    size: AppConstants.largeAvatarSize,
                    menuFunctions: postReport.genMenuFunctions(modToolTracker: modToolTracker, inboxTracker: modInboxTracker)
                )
            }
            
            Text(postReport.postReport.reason)
            
            Text("Post reported \(postReport.published.getRelativeTime())")
                .italic()
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            if let resolver = postReport.resolver {
                let verb = postReport.postReport.resolved ? "Resolved" : "Unresolved"
                Text("\(verb) by \(resolver.fullyQualifiedUsername ?? resolver.name)")
                    .italic()
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            
            EmbeddedPost(community: postReport.community.community, post: postReport.post, comment: nil)
        }
        .padding(.top, AppConstants.standardSpacing)
        .padding(.horizontal, AppConstants.standardSpacing)
    }
}
