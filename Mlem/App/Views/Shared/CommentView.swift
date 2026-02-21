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
    @Environment(NavigationLayer.self) var navigation
    @Environment(\.communityContext) var communityContext: Community?
    @Environment(\.reportContext) private var reportContext: Report?
    @Environment(\.palette) private var palette
    
    @Setting(\.comment_compact) var compactComments
    @Setting(\.menus_modActionGrouping) var moderatorActionGrouping
    @Setting(\.interactionBar_comment) var commentInteractionBar
    @Setting(\.interactionBar_commentReport) var commentReportInteractionBar
    @Setting(\.interactionBar_alternateReportLayout) var alternateInteractionBarLayoutForReports
    
    private let indent: CGFloat = 10
    
    let comment: Comment
    
    /// If the `CommentView` is rendered in an `ExpandedPostView`, this object can be used to access collapsed state etc.
    let treeNode: CommentTreeNode?
    
    let embeddedContent: EmbeddedContent
    let inFeed: Bool
    let highlight: Bool
    let depthOffset: Int
    
    init(
        comment: Comment,
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
    
    var collapsed: Bool { treeNode?.collapsed ?? false }
    
    var compact: Bool { compactComments && reportContext == nil }
    
    @ViewBuilder
    var body: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            if inFeed {
                feedHeader
                    .padding(.trailing, Constants.main.standardSpacing)
            }
            
            HStack(spacing: 0) {
                CommentBarView(depth: comment.depth, inFeed: inFeed)
                
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: Constants.main.compactSpacing) {
                        if !inFeed {
                            authorAndMenu.padding(.top, Constants.main.standardSpacing)
                        }
                        
                        if !collapsed {
                            CommentBodyView(comment: comment)
                                .padding(.trailing, 2)
                            embeddedContent
                        }
                        
                        if compact, !collapsed {
                            InfoStackView(
                                comment: comment,
                                readouts: commentInteractionBar.readouts,
                                coloredReadouts: .init(CommentBarConfiguration.ReadoutType.allCases)
                            )
                            .layoutPriority(1)
                        }
                    }
                    .padding(.horizontal, Constants.main.standardSpacing)
                    .padding(.leading, 2)
                    
                    if !compact, !collapsed {
                        InteractionBarView(
                            appState: appState,
                            navigation: navigation,
                            comment: comment,
                            configuration: interactionBarConfiguration,
                            commentTreeTracker: commentTreeTracker,
                            communityContext: communityContext,
                            reportContext: reportContext
                        )
                    }
                }
                .padding(.bottom, collapsed || compact ? Constants.main.standardSpacing : 0)
            }
        }
        .background(highlight ? palette.accent.opacity(0.2) : .clear)
        .background(.themedSecondaryGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .contentShape(.interaction, .rect)
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .environment(\.commentContext, comment)
        .environment(\.communityContext, comment.community.value)
        .paletteBorder(cornerRadius: Constants.main.standardSpacing)
    }
    
    var feedHeader: some View {
        VStack(spacing: Constants.main.standardSpacing) {
            authorAndMenu
            
            ExpectedView(comment.post) { post in
                FooterLinkView(title: post.title, subtitle: nil)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding([.leading, .top], Constants.main.standardSpacing)
    }
    
    var authorAndMenu: some View {
        HStack(spacing: 0) {
            ExpectedView(comment.creator) { creator in
                FullyQualifiedLinkView(creator, labelStyle: .small)
            } placeholder: {
                Text(verbatim: .personPlaceholder).redacted(reason: .placeholder)
            }
            Spacer()
            Group {
                if collapsed {
                    Image(icon: .general.expand)
                        .frame(height: 10)
                        .imageScale(.small)
                } else {
                    ellipsisMenus
                        .frame(height: 10)
                }
            }
            .padding(.leading, Constants.main.standardSpacing)
        }
    }
    
    var ellipsisMenus: some View {
        HStack {
            if comment.shouldShowLoadingSymbol(for: commentInteractionBar) {
                ProgressView()
            }
            switch moderatorActionGrouping {
            case .separateMenu:
                if comment.canModerate {
                    EllipsisMenu(icon: .lemmy.moderation, size: 24, comment: comment, type: [.moderator])
                }
                EllipsisMenu(size: 24, comment: comment, type: [.basic])
            case .disclosureGroup:
                EllipsisMenu(size: 24) {
                    comment.allMenuActions(
                        appState: appState,
                        showAllActions: !inFeed,
                        navigation: navigation,
                        commentTreeTracker: commentTreeTracker,
                        report: reportContext
                    )
                }
            case .divider:
                if reportContext != nil {
                    EllipsisMenu(size: 24) {
                        comment.allMenuActions(
                            appState: appState,
                            showAllActions: !inFeed,
                            navigation: navigation,
                            commentTreeTracker: commentTreeTracker,
                            report: reportContext
                        )
                    }
                } else {
                    EllipsisMenu(size: 24, comment: comment)
                }
            }
        }
    }
    
    var interactionBarConfiguration: CommentBarConfiguration {
        if reportContext != nil, alternateInteractionBarLayoutForReports {
            return commentReportInteractionBar
        }
        return commentInteractionBar
    }
}

struct CommentBarView: View {
    let depth: Int
    var inFeed: Bool = false
    
    var body: some View {
        Capsule()
            .fill(inFeed ? .themedTertiary : .themedCommentIndentColor(depth))
            .frame(width: 3)
            .frame(maxHeight: .infinity)
            .padding(.leading, 8)
            .padding(.bottom, 8)
            .padding(.top, inFeed ? 0 : 8)
    }
}

// TODO: updated mocks
// #if DEBUG
//    #Preview(traits: .sampleEnvironment, .sizeThatFitsLayout) {
//        CommentView(comment: Comment2.mock(.generic))
//    }
// #endif
