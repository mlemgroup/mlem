//
//  CommentView.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct CommentView<EmbeddedContent: View>: View {
    @Environment(AppState.self) var appState
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(\.reportContext) private var reportContext: Report?
    @Environment(\.self) private var environment
    
    @Setting(\.compactComments) var compactComments
    @Setting(\.tapCommentsToCollapse) var tapCommentsToCollapse
    @Setting(\.moderatorActionGrouping) var moderatorActionGrouping
    @Setting(\.alternateInteractionBarLayoutForReports) var alternateInteractionBarLayoutForReports
    
    private let indent: CGFloat = 10
    
    let comment: any Comment1Providing
    
    /// If the `CommentView` is rendered in an `ExpandedPostView`, this object can be used to access collapsed state etc.
    let treeNode: CommentTreeNode?
    
    let embeddedContent: EmbeddedContent
    let inFeed: Bool
    let highlight: Bool
    let depthOffset: Int
    
    init(
        comment: any Comment1Providing,
        treeNode: CommentTreeNode? = nil,
        inFeed: Bool = false, // flag to suppress threading/collapsing behavior
        highlight: Bool = false,
        depthOffset: Int = 0,
        @ViewBuilder embeddedContent: () -> EmbeddedContent = { EmptyView() }
    ) {
        self.comment = comment
        self.treeNode = treeNode
        self.inFeed = inFeed
        self.highlight = highlight
        self.depthOffset = depthOffset
        self.embeddedContent = embeddedContent()
    }
    
    var depth: Int {
        inFeed ? 0 : comment.depth - depthOffset
    }
    
    var body: some View {
        if inFeed {
            content
        } else {
            content
                .onTapGesture {
                    if tapCommentsToCollapse, let treeNode {
                        withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
                            treeNode.collapsed.toggle()
                        }
                    }
                }
        }
    }
    
    var compact: Bool { compactComments && reportContext == nil }
    
    @ViewBuilder
    var content: some View {
        let collapsed = treeNode?.collapsed ?? false
        
        HStack(spacing: 12) {
            if !inFeed, comment.depth != 0 {
                CommentBarView(depth: comment.depth)
            }
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack(spacing: 0) {
                    FullyQualifiedLinkView(comment.creator_, labelStyle: .small)
                    Spacer()
                    if compact {
                        InfoStackView(
                            comment: comment,
                            readouts: InteractionBarTracker.main.commentInteractionBar.readouts,
                            showColor: true
                        )
                        .layoutPriority(1)
                    }
                    Group {
                        if collapsed {
                            Image(systemName: Icons.expandComment)
                                .frame(height: 10)
                                .imageScale(.small)
                        } else {
                            ellipsisMenus
                                .frame(height: 10)
                        }
                    }
                    .padding(.leading, Constants.main.standardSpacing)
                }
                if !collapsed {
                    CommentBodyView(comment: comment)
                        .padding(.trailing, 2)
                    if inFeed, let post = comment.post_ {
                        NavigationLink(.post(post)) {
                            FooterLinkView(title: post.title, subtitle: comment.community_?.fullNameWithPrefix)
                        }
                        .id("\(comment.id)_commment_footer")
                    }
                    embeddedContent
                    if !compact {
                        InteractionBarView(
                            appState: appState,
                            comment: comment,
                            configuration: interactionBarConfiguration,
                            commentTreeTracker: commentTreeTracker,
                            communityContext: communityContext,
                            reportContext: reportContext
                        )
                        .padding(.horizontal, 2)
                        .padding(.bottom, 5)
                        .padding(.top, 1)
                    }
                }
            }
            .padding(.vertical, Constants.main.standardSpacing)
            .padding(.top, compact || collapsed ? 0 : 3)
        }
        .padding(depth == 0 ? .horizontal : .trailing, Constants.main.standardSpacing)
        .background(highlight ? .themedAccent.resolve(in: environment).opacity(0.2) : .clear)
        .background(.themedSecondaryGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.interaction, .rect)
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .environment(\.commentContext, comment)
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
    
    var ellipsisMenus: some View {
        HStack {
            if comment.shouldShowLoadingSymbol(for: InteractionBarTracker.main.commentInteractionBar) {
                ProgressView()
            }
            if moderatorActionGrouping == .separateMenu {
                if comment.canModerate {
                    EllipsisMenu(systemImage: Icons.moderation, size: 24) {
                        comment.moderatorMenuActions(appState: appState, showAllActions: !inFeed, report: reportContext)
                    }
                }
                EllipsisMenu(size: 24) {
                    comment.basicMenuActions(appState: appState, commentTreeTracker: commentTreeTracker)
                }
            } else {
                EllipsisMenu(size: 24) {
                    comment.allMenuActions(
                        appState: appState,
                        showAllActions: !inFeed,
                        commentTreeTracker: commentTreeTracker,
                        report: reportContext
                    )
                }
            }
        }
    }
    
    var interactionBarConfiguration: CommentBarConfiguration {
        if reportContext != nil, alternateInteractionBarLayoutForReports {
            return InteractionBarTracker.main.commentReportInteractionBar
        }
        return InteractionBarTracker.main.commentInteractionBar
    }
}

struct CommentBarView: View {
    let depth: Int
    
    var body: some View {
        Capsule()
            .fill(.themedCommentIndentColor(depth))
            .frame(width: 3)
            .frame(maxHeight: .infinity)
            .padding(.leading, 8)
            .padding(.vertical, 8)
    }
}
