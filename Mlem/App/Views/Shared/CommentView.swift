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
    
    private let indent: CGFloat = 10
    
    let comment: any Comment1Providing
    var highlight: Bool = false
    var inFeed: Bool = false // flag to suppress threading/collapsing behavior
    var depthOffset: Int = 0
    
    var depth: Int { inFeed ? 0 : comment.depth - depthOffset }
    
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
            Capsule()
                .fill(palette.commentIndentColors[depth % palette.commentIndentColors.count])
                .frame(width: 4)
                .frame(maxHeight: .infinity)
                .padding(.leading, 8)
                .padding(.vertical, -2)
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
                            EllipsisMenu(size: 24) { comment.menuActions(commentTreeTracker: commentTreeTracker) }
                                .frame(height: 10)
                        }
                    }
                    .padding(.leading, Constants.main.standardSpacing)
                }
                if !collapsed {
                    CommentBodyView(comment: comment)
                    if !compactComments {
                        InteractionBarView(
                            comment: comment,
                            configuration: InteractionBarTracker.main.commentInteractionBar,
                            commentTreeTracker: commentTreeTracker,
                            communityContext: communityContext
                        )
                        .padding(.top, 2)
                    }
                }
            }
        }
        .padding(.vertical, 2)
        .padding([.vertical, .trailing], Constants.main.standardSpacing)
        .background(highlight ? palette.accent.opacity(0.2) : .clear)
        .background(palette.secondaryGroupedBackground)
//            .border(
//                width: depth == 0 ? 0 : 2, edges: [.leading],
//                color: palette.commentIndentColors[depth % palette.commentIndentColors.count]
//            )
        .quickSwipes(comment.swipeActions(behavior: .standard, commentTreeTracker: commentTreeTracker))
        .contentShape(.rect)
        .contextMenu { comment.menuActions(commentTreeTracker: commentTreeTracker) }
        .clipShape(.rect(cornerRadius: 12))
        .padding(.vertical, 2)
        .padding(.trailing, 10)
        // .shadow(color: palette.commentIndentColors[depth % palette.commentIndentColors.count], radius: 4)
        // Divider()
        .padding(.leading, CGFloat(depth) * indent)
        .environment(\.commentContext, comment)
    }
}
