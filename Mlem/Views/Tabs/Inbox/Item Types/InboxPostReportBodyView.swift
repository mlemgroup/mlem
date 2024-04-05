//
//  InboxPostReportBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2024-04-04.
//

import Foundation
import SwiftUI

struct InboxPostReportBodyView: View {
    @EnvironmentObject var layoutWidgetTracker: LayoutWidgetTracker
    @EnvironmentObject var modToolTracker: ModToolTracker
    @EnvironmentObject var modInboxTracker: InboxTracker
    
    @ObservedObject var postReport: PostReportModel
    
    var iconName: String { postReport.postReport.resolved ? Icons.posts : Icons.postsFill }
    
    var body: some View {
        content
            .background(Color(uiColor: .systemBackground))
            .contentShape(Rectangle())
            .contextMenu {
                ForEach(postReport.genMenuFunctions(modToolTracker: modToolTracker, inboxTracker: modInboxTracker)) { menuFunction in
                    MenuButton(menuFunction: menuFunction, menuFunctionPopup: .constant(nil))
                }
            }
    }
    
    var content: some View {
        VStack(spacing: 0) {
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
            
            InteractionBarView(context: .post, widgets: enrichLayoutWidgets())
        }
    }
    
    func toggleResolved() {
        Task(priority: .userInitiated) {
            await postReport.toggleResolved()
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
                    postReport.togglePostRemoved(modToolTracker: modToolTracker)
                }
            case .purge:
                return .purge(purged: postReport.purged) {
                    postReport.purgePost(modToolTracker: modToolTracker)
                }
            case .ban:
                return .ban(banned: postReport.postCreatorBannedFromCommunity, instanceBan: false) {
                    postReport.togglePostCreatorBanned(modToolTracker: modToolTracker, inboxTracker: modInboxTracker)
                }
            default:
                return nil
            }
        }
    }
}
