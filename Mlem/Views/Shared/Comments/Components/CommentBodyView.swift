//
//  CommentBodyView.swift
//  Mlem
//
//  Created by Eric Andrews on 2023-07-03.
//

import Dependencies
import SwiftUI

struct CommentBodyView: View {
    @Dependency(\.siteInformation) var siteInformation
    
    @AppStorage("shouldShowUserServerInComment") var shouldShowUserServerInComment: Bool = false
    @AppStorage("compactComments") var compactComments: Bool = false
    @AppStorage("showCommentDownvotesSeparately") var showCommentDownvotesSeparately: Bool = false
    @AppStorage("easyTapLinkDisplayMode") var easyTapLinkDisplayMode: EasyTapLinkDisplayMode = .contextual
    @AppStorage("moderatorActionGrouping") var moderatorActionGrouping: ModerationActionGroupingMode = .none
    
    @Binding var isParentCollapsed: Bool
    @Binding var isCollapsed: Bool
    
    let commentView: APICommentView
    let showPostContext: Bool
    let commentorLabel: String
    var combinedMenuFunctions: [MenuFunction]
    let personalMenuFunctions: [MenuFunction]
    let modMenuFunctions: [MenuFunction]
    let links: [LinkType]
    
    var myVote: ScoringOperation { commentView.myVote ?? .resetVote }
    
    var serverInstanceLocation: ServerInstanceLocation {
        if !shouldShowUserServerInComment {
            return .disabled
        } else if compactComments {
            return .trailing
        } else {
            return .bottom
        }
    }
    
    var showLinkCaptions: Bool {
        switch easyTapLinkDisplayMode {
        case .large: true
        case .compact: false
        case .contextual: !compactComments
        case .disabled: true // doesn't matter, just needs some value
        }
    }
    
    var isMod: Bool {
        siteInformation.isModOrAdmin(communityId: commentView.post.communityId)
    }
    
    var spacing: CGFloat { compactComments ? AppConstants.compactSpacing : AppConstants.postAndCommentSpacing }
    
    init(
        commentView: APICommentView,
        isParentCollapsed: Binding<Bool>,
        isCollapsed: Binding<Bool>,
        showPostContext: Bool,
        combinedMenuFunctions: [MenuFunction] = [],
        personalMenuFunctions: [MenuFunction] = [],
        modMenuFunctions: [MenuFunction] = [],
        links: [LinkType] = []
    ) {
        self._isParentCollapsed = isParentCollapsed
        self._isCollapsed = isCollapsed
        
        self.commentView = commentView
        self.showPostContext = showPostContext
        self.combinedMenuFunctions = combinedMenuFunctions
        self.personalMenuFunctions = personalMenuFunctions
        self.modMenuFunctions = modMenuFunctions
        self.links = links
        
        let commentor = commentView.creator
        let publishedAgo: String = getTimeIntervalFromNow(date: commentView.comment.published)
        self.commentorLabel = "Last updated \(publishedAgo) ago by \(commentor.displayName ?? commentor.name)"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            HStack(spacing: AppConstants.compactSpacing) {
                UserLinkView(
                    person: commentView.creator,
                    serverInstanceLocation: serverInstanceLocation,
                    bannedFromCommunity: commentView.creatorBannedFromCommunity,
                    postContext: commentView.post,
                    commentContext: commentView.comment
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(commentorLabel)
                .foregroundColor(.secondary)
                
                Spacer()
                
                if compactComments {
                    compactScoreDisplay()
                }
                
                let menuSize: CGFloat = compactComments ? 20 : 24
                if moderatorActionGrouping == .separateMenu {
                    if isMod {
                        EllipsisMenu(
                            size: menuSize,
                            systemImage: siteInformation.isAdmin ? Icons.admin : Icons.moderation,
                            menuFunctions: modMenuFunctions
                        )
                        .opacity(modMenuFunctions.isEmpty ? 0.5 : 1)
                    }
                    EllipsisMenu(size: menuSize, menuFunctions: personalMenuFunctions)
                } else {
                    EllipsisMenu(size: menuSize, menuFunctions: combinedMenuFunctions)
                }
            }
            
            // comment text or placeholder
            Group {
                if commentView.comment.deleted {
                    Text("Comment was deleted")
                        .italic()
                        .foregroundColor(.secondary)
                } else if commentView.comment.removed {
                    Text("Comment was removed")
                        .italic()
                        .foregroundColor(.secondary)
                } else if !isCollapsed {
                    MarkdownView(text: commentView.comment.content, isNsfw: commentView.post.nsfw)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .transition(.markdownView())
                    
                    if easyTapLinkDisplayMode != .disabled {
                        ForEach(links) { link in
                            EasyTapLinkView(linkType: link, showCaption: showLinkCaptions)
                        }
                    }
                }
            }
            
            // embedded post
            if showPostContext {
                EmbeddedPost(
                    community: commentView.community,
                    post: commentView.post,
                    comment: commentView.comment
                )
            }
        }
    }
    
    @ViewBuilder
    func compactScoreDisplay() -> some View {
        Group {
            // time
            if let updated = commentView.comment.updated {
                UpdatedTimestampView(date: updated, spacing: AppConstants.iconToTextSpacing)
            } else {
                PublishedTimestampView(date: commentView.comment.published)
            }
            
            // votes
            if showCommentDownvotesSeparately {
                HStack(spacing: AppConstants.iconToTextSpacing) {
                    Image(systemName: myVote == .upvote ? Icons.upvoteSquareFill : Icons.upvoteSquare)
                    Text(String(commentView.counts.upvotes))
                }
                .foregroundColor(myVote == .upvote ? .upvoteColor : .secondary)
                
                HStack(spacing: AppConstants.iconToTextSpacing) {
                    Image(systemName: myVote == .downvote ? Icons.downvoteSquareFill : Icons.downvoteSquare)
                    Text(String(commentView.counts.downvotes))
                }
                .foregroundColor(myVote == .downvote ? .downvoteColor : .secondary)
            } else {
                HStack(spacing: AppConstants.iconToTextSpacing) {
                    Image(systemName: myVote == .resetVote ? Icons.upvoteSquare : myVote.iconNameFill)
                    Text(String(commentView.counts.score))
                }
                .foregroundColor(myVote.color ?? .secondary)
                .font(.footnote)
            }
        }
        .foregroundColor(.secondary)
        .font(.footnote)
    }
}
