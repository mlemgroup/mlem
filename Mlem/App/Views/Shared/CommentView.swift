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
    @Environment(Palette.self) private var palette
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    @Environment(\.reportContext) private var reportContext: Report?
    
    @Setting(\.compactComments) var compactComments
    @Setting(\.tapCommentsToCollapse) var tapCommentsToCollapse
    @Setting(\.moderatorActionGrouping) var moderatorActionGrouping

    private let indent: CGFloat = 10
    
    let comment: any Comment1Providing
    let embeddedContent: EmbeddedContent
    let inFeed: Bool
    let highlight: Bool
    let depthOffset: Int
    
    init(
        comment: any Comment1Providing,
        inFeed: Bool = false, // flag to suppress threading/collapsing behavior
        highlight: Bool = false,
        depthOffset: Int = 0,
        @ViewBuilder embeddedContent: () -> EmbeddedContent = { EmptyView() }
    ) {
        self.comment = comment
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
                    if tapCommentsToCollapse, let comment = comment as? CommentWrapper {
                        withAnimation(UIAccessibility.isReduceMotionEnabled ? nil : .default) {
                            comment.collapsed.toggle()
                        }
                    }
                }
        }
    }
    
    @ViewBuilder
    var content: some View {
        let collapsed = (comment as? CommentWrapper)?.collapsed ?? false
        
        HStack(spacing: 12) {
            if !inFeed, comment.depth != 0 {
                CommentBarView(depth: comment.depth)
            }
            VStack(alignment: .leading, spacing: Constants.main.standardSpacing) {
                HStack(spacing: 0) {
                    FullyQualifiedLinkView(
                        entity: comment.creator_,
                        labelStyle: .small,
                        showAvatar: true
                    )
                    Spacer()
                    if compactComments {
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
                    if !compactComments {
                        InteractionBarView(
                            comment: comment,
                            configuration: InteractionBarTracker.main.commentInteractionBar,
                            commentTreeTracker: commentTreeTracker,
                            communityContext: communityContext
                        )
                        .padding(.horizontal, 2)
                        .padding(.bottom, 5)
                        .padding(.top, 1)
                    }
                }
            }
            .padding(.vertical, Constants.main.standardSpacing)
            .padding(.top, compactComments || collapsed ? 0 : 3)
        }
        .padding(depth == 0 ? .horizontal : .trailing, Constants.main.standardSpacing)
        .background(highlight ? palette.accent.opacity(0.2) : .clear)
        .background(palette.secondaryGroupedBackground)
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
                        comment.moderatorMenuActions(showAllActions: !inFeed, report: reportContext)
                    }
                }
                EllipsisMenu(size: 24) {
                    comment.basicMenuActions(commentTreeTracker: commentTreeTracker)
                }
            } else {
                EllipsisMenu(size: 24) {
                    comment.allMenuActions(showAllActions: !inFeed, commentTreeTracker: commentTreeTracker, report: reportContext)
                }
            }
        }
    }
}

struct CommentBarView: View {
    @Environment(Palette.self) var palette
    
    let depth: Int
    
    var body: some View {
        Capsule()
            .fill(palette.commentIndentColors[depth % palette.commentIndentColors.count])
            .frame(width: 3)
            .frame(maxHeight: .infinity)
            .padding(.leading, 8)
            .padding(.vertical, 8)
    }
}
