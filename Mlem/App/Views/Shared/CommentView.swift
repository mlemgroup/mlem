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
    
    var threadingColor: Color { palette.commentIndentColors[depth % palette.commentIndentColors.count] }
    
    @ViewBuilder
    var content: some View {
        let collapsed = (comment as? CommentWrapper)?.collapsed ?? false
        
        VStack(spacing: 0) {
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
            .padding(10)
            .padding(.vertical, 2)
            .padding(Constants.main.standardSpacing)
            .clipped()
            .background(highlight ? palette.accent.opacity(0.2) : .clear)
            .border(
                width: depth == 0 ? 0 : 2, edges: [.leading],
                color: threadingColor
            )
            .background(palette.background)
            .quickSwipes(comment.swipeActions(behavior: .standard, commentTreeTracker: commentTreeTracker))
            .clipShape(
                .rect(
                    topLeadingRadius: depth == 0 ? 10 : 0,
                    bottomLeadingRadius: 10,
                    bottomTrailingRadius: 00,
                    topTrailingRadius: depth == 0 ? 10 : 0
                )
            )
            .background {
                UnevenRoundedRectangle(
                    topLeadingRadius: depth == 0 ? 10 : 0,
                    bottomLeadingRadius: 10,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: depth == 0 ? 10 : 0
                )
                .fill(palette.background)
                .shadow(radius: 5)
            }
            .contentShape(.rect)
            .contextMenu { comment.menuActions(commentTreeTracker: commentTreeTracker) }
        }
        .padding(.top, depth == 0 ? 10 : 0)
        .padding(.leading, CGFloat(depth) * indent)
        .environment(\.commentContext, comment)
    }
}
