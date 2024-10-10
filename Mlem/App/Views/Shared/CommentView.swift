//
//  CommentView.swift
//  Mlem
//
//  Created by Sjmarf on 25/06/2024.
//

import LemmyMarkdownUI
import MlemMiddleware
import SwiftUI

struct CommentView: View {
    @Environment(Palette.self) private var palette
    @Environment(CommentTreeTracker.self) private var commentTreeTracker: CommentTreeTracker?
    @Environment(\.communityContext) var communityContext: (any Community1Providing)?
    
    @Setting(\.compactComments) var compactComments
    @Setting(\.moderatorActionGrouping) var moderatorActionGrouping

    private let indent: CGFloat = 10
    
    let comment: any Comment1Providing
    var highlight: Bool = false
    var inFeed: Bool = false // flag to suppress threading/collapsing behavior
    var depthOffset: Int = 0
    
    var depth: Int {
        inFeed ? 0 : comment.depth - depthOffset
    }
    
    var body: some View {
        if inFeed {
            content
        } else {
            content
                .onTapGesture {
                    if let comment = comment as? CommentWrapper {
                        withAnimation {
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
//                            EllipsisMenu(size: 24) { comment.menuActions(commentTreeTracker: commentTreeTracker) }
                                .frame(height: 10)
                        }
                    }
                    .padding(.leading, Constants.main.standardSpacing)
                }
                if !collapsed {
                    CommentBodyView(comment: comment)
                        .padding(.trailing, 2)
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
            .padding(.top, compactComments ? 0 : 3)
        }
        .padding(depth == 0 ? .horizontal : .trailing, Constants.main.standardSpacing)
        .background(highlight ? palette.accent.opacity(0.2) : .clear)
        .background(palette.secondaryGroupedBackground)
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .quickSwipes(comment.swipeActions(behavior: .standard, commentTreeTracker: commentTreeTracker))
        .contentShape(.interaction, .rect)
        .contentShape(.contextMenuPreview, .rect(cornerRadius: Constants.main.standardSpacing))
        .contextMenu { comment.allMenuActions(commentTreeTracker: commentTreeTracker) }
        .clipShape(.rect(cornerRadius: Constants.main.standardSpacing))
        .environment(\.commentContext, comment)
    }
    
    var ellipsisMenus: some View {
        HStack {
            if comment.shouldShowLoadingSymbol(for: InteractionBarTracker.main.commentInteractionBar) {
                ProgressView()
            }
            if moderatorActionGrouping == .separateMenu {
                if comment.canModerate {
                    EllipsisMenu(systemImage: Icons.moderation, size: 24) {
                        comment.moderatorMenuActions()
                    }
                }
                EllipsisMenu(size: 24) {
                    comment.basicMenuActions(commentTreeTracker: commentTreeTracker)
                }
            } else {
                EllipsisMenu(size: 24) {
                    comment.allMenuActions(commentTreeTracker: commentTreeTracker)
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
